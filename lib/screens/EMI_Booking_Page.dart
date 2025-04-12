import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Model/Car_Mode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class EmiBookingPage extends StatefulWidget {
  final Car car;

  const EmiBookingPage({Key? key, required this.car}) : super(key: key);

  @override
  State<EmiBookingPage> createState() => _EmiBookingPageState();
}

class _EmiBookingPageState extends State<EmiBookingPage> {
  late double loanAmount;
  double interestRate = 6.5;
  int loanTenure = 12;
  String userName = "";
  String userPhone = "";
  String registeredAddress = "Loading...";
  List<String> savedAddresses = [];
  final _alternateAddressController = TextEditingController();
  bool useSavedAddress = true;
  String selectedAddress = "";

  @override
  void initState() {
    super.initState();
    loanAmount = widget.car.totalPrice;
    fetchUserData();
  }

  void fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in");
      return;
    }

    DatabaseReference userRef = FirebaseDatabase.instance.ref("users/${user.uid}");
    DatabaseEvent event = await userRef.once();

    if (event.snapshot.value != null) {
      print("Fetched Data: ${event.snapshot.value}"); // Debugging log

      if (event.snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> data = Map<String, dynamic>.from(event.snapshot.value as Map);

        setState(() {
          userName = data["name"] ?? "Unknown";
          userPhone = data["phone"] ?? "No Phone";
          registeredAddress = data["address"] ?? "No Address";
          selectedAddress = registeredAddress;
        });

        print("Updated User Data -> Name: $userName, Phone: $userPhone, Address: $registeredAddress");
      }
    } else {
      print("No data found for user.");
    }
  }

  int calculateEMI() {
    double monthlyInterestRate = (interestRate / 100) / 12;
    int months = loanTenure;
    double emi = (loanAmount * monthlyInterestRate * pow(1 + monthlyInterestRate, months)) /
        (pow(1 + monthlyInterestRate, months) - 1);
    return emi.round();
  }

  Future<void> fetchUserDataAndWait() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DatabaseReference userRef = FirebaseDatabase.instance.ref("users/${user.uid}");
    DatabaseEvent event = await userRef.once();

    if (event.snapshot.value != null) {
      print("Fetched Data: ${event.snapshot.value}"); // Debugging log

      if (event.snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> data = Map<String, dynamic>.from(event.snapshot.value as Map);

        // Ensuring state updates properly before proceeding
        setState(() {
          userName = data["name"] ?? "Unknown";
          userPhone = data["phone"] ?? "No Phone";
          registeredAddress = data["address"] ?? "No Address";
          selectedAddress = registeredAddress;
        });

        print("Updated User Data -> Name: $userName, Phone: $userPhone, Address: $registeredAddress");
      }
    } else {
      print("No data found for user.");
    }
  }


  void saveEMIToFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in!")));
      return;
    }

    // Fetch user data and wait until it's updated
    await fetchUserDataAndWait();

    String finalAddress = useSavedAddress ? selectedAddress : _alternateAddressController.text.trim();
    if (finalAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please provide an address!")));
      return;
    }

    String userId = user.uid;
    DatabaseReference dbRef = FirebaseDatabase.instance.ref("EMI_Bookings/$userId").push();

    Map<String, dynamic> emiData = {
      "user_name": userName,
      "user_phone": userPhone,
      "user_address": finalAddress,
      "car_name": widget.car.name,
      "car_price": widget.car.totalPrice.round(),
      "loan_amount": loanAmount.round(),
      "interest_rate": interestRate.round(),
      "loan_time(months)": loanTenure,
      "monthly_emi": calculateEMI(),
      "total_amount_payable": calculateEMI() * loanTenure,
      "timestamp": DateTime.now().toIso8601String(),
    };

    try {
      await dbRef.set(emiData);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("EMI Booking Confirmed!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error saving EMI details!")));
    }
  }



  @override
  Widget build(BuildContext context) {
    int totalAmount = calculateEMI() * loanTenure;
    int interestAmount = totalAmount - loanAmount.round();

    return Scaffold(
      appBar: AppBar(title: const Text('EMI Booking')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: CircularProgressIndicator(
                        value: loanAmount / totalAmount,
                        strokeWidth: 14,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation(Colors.purpleAccent),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        Text(
                          '₹ $totalAmount',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('₹ ${calculateEMI()}/mo',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: selectedAddress,
                hint: const Text("Select Address"),
                items: savedAddresses.map((address) {
                  return DropdownMenuItem(
                    value: address,
                    child: Text(address),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAddress = value!;
                  });
                },
              ),
              SwitchListTile(
                title: const Text("Use Saved Address"),
                value: useSavedAddress,
                onChanged: (value) {
                  setState(() {
                    useSavedAddress = value;
                    if (value) {
                      selectedAddress = registeredAddress;
                    }
                  });
                },
              ),
              if (!useSavedAddress)
                TextField(
                  controller: _alternateAddressController,
                  decoration: const InputDecoration(labelText: "Enter New Address"),
                ),
              _buildSlider('Rate of Interest', interestRate, 1, 15, (value) {
                setState(() => interestRate = value);
              }, isPercentage: true),
              _buildSlider('Loan Tenure', loanTenure.toDouble(), 12, 60, (value) {
                setState(() => loanTenure = value.toInt());
              }, isPercentage: false),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveEMIToFirebase,
                child: const Text('Confirm EMI Booking'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildSlider(String title, double value, double min, double max, Function(double) onChanged, {bool isPercentage = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ${value.round()}${isPercentage ? "%" : " months"}',
          style: const TextStyle(fontSize: 16),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}