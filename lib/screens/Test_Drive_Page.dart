import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Assistance/ColorHelper.dart';
import '../Model/Car_Mode.dart';
import '../Model/user_model.dart';
import '../global/global.dart';
import '../screens/login_screen.dart';

class TestDrivePage extends StatefulWidget {
  final Car car;

  const TestDrivePage({Key? key, required this.car}) : super(key: key);

  @override
  State<TestDrivePage> createState() => _TestDrivePageState();
}

class _TestDrivePageState extends State<TestDrivePage> {
  final _alternateAddressController = TextEditingController();
  bool _useRegisteredAddress = true;
  String _registeredAddress = 'Loading...';

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();


    if (isGuest || FirebaseAuth.instance.currentUser == null) {
      return;
    }

    _fetchRegisteredAddress();
  }

  Future<void> _fetchRegisteredAddress() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final dbRef = FirebaseDatabase.instance.ref().child('users/$userId');
    try {
      final snapshot = await dbRef.get();
      if (snapshot.exists) {
        final userModel = UserModel.fromSnapshot(snapshot);
        setState(() {
          _registeredAddress = userModel.address ?? 'No address found';
        });
      } else {
        setState(() {
          _registeredAddress = 'No registered address found';
        });
      }
    } catch (_) {
      setState(() {
        _registeredAddress = 'Error fetching address';
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _confirmBooking() async {
    if (isGuest) return;

    final selectedAddress = _useRegisteredAddress
        ? _registeredAddress
        : _alternateAddressController.text.trim();

    if (selectedAddress.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final snapshot =
      await FirebaseDatabase.instance.ref('users/$userId').get();
      if (!snapshot.exists) return;

      final userModel = UserModel.fromSnapshot(snapshot);

      final bookingData = {
        'carName': widget.car.name,
        'price': widget.car.totalPrice,
        'address': selectedAddress,
        'userName': userModel.name ?? '',
        'userEmail': userModel.email ?? '',
        'userPhone': userModel.phone ?? '',
        'testDriveDate': _selectedDate.toString(),
        'testDriveTime': _selectedTime!.format(context),
        'timestamp': DateTime.now().toString(),
        'status': 'pending',
      };

      await FirebaseDatabase.instance
          .ref('testDrive/$userId')
          .push()
          .set(bookingData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test Drive Confirmed!')),
      );

      Navigator.pop(context);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to confirm test drive')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Test Drive"),
        backgroundColor: ColorSys.purple2,
      ),


      body: isGuest || FirebaseAuth.instance.currentUser == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline,
                size: 80, color: Colors.grey),
            const SizedBox(height: 15),
            const Text(
              "Login Required",
              style:
              TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please login to book a test drive",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: ColorSys.purple1),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LoginScreen()),
                );
              },
              child: const Text("Go to Login"),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Car: ${widget.car.name}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Price: ₹${widget.car.totalPrice}',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),


            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Address:',
                        style:
                        TextStyle(fontWeight: FontWeight.bold)),
                    RadioListTile<bool>(
                      title: Text(
                          'Registered Address: $_registeredAddress'),
                      value: true,
                      groupValue: _useRegisteredAddress,
                      onChanged: (v) =>
                          setState(() => _useRegisteredAddress = v!),
                    ),
                    RadioListTile<bool>(
                      title:
                      const Text('Use Alternate Address'),
                      value: false,
                      groupValue: _useRegisteredAddress,
                      onChanged: (v) =>
                          setState(() => _useRegisteredAddress = v!),
                    ),
                    if (!_useRegisteredAddress)
                      TextField(
                        controller: _alternateAddressController,
                        decoration: const InputDecoration(
                            labelText: 'Enter Alternate Address',
                            border: OutlineInputBorder()),
                        maxLines: 3,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),


            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Test Drive Date & Time:',
                      style:
                      TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        onPressed: _selectDate,
                        child: const Text('Pick Date')),
                    const SizedBox(height: 8),
                    ElevatedButton(
                        onPressed: _selectTime,
                        child: const Text('Pick Time')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorSys.purple1,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 16),
                ),
                child: const Text('Confirm Test Drive',
                    style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _alternateAddressController.dispose();
    super.dispose();
  }
}
