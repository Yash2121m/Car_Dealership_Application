import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Assistance/ColorHelper.dart';
import '../Model/Car_Mode.dart';
import '../Model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    _fetchRegisteredAddress();
  }

  Future<void> _fetchRegisteredAddress() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() {
        _registeredAddress = 'User not logged in';
      });
      return;
    }
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
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 60)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: Colors.deepPurple),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: Colors.deepPurple),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _confirmBooking() async {
    final selectedAddress =
    _useRegisteredAddress ? _registeredAddress : _alternateAddressController.text.trim();

    if (selectedAddress.isEmpty || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      final snapshot = await FirebaseDatabase.instance.ref('users/$userId').get();
      if (snapshot.exists) {
        final userModel = UserModel.fromSnapshot(snapshot);
        final bookingData = {
          'carName': widget.car.name,
          'price': widget.car.totalPrice,
          'address': selectedAddress,
          'userName': userModel.name ?? 'Unknown User',
          'userEmail': userModel.email ?? 'No Email',
          'userPhone': userModel.phone ?? 'No Phone',
          'testDriveDate': _selectedDate.toString(),
          'testDriveTime': _selectedTime!.format(context),
          'timestamp': DateTime.now().toString(),
          'status': 'pending', // 🔹 Default status
        };
        await FirebaseDatabase.instance.ref('testDrive/$userId').push().set(bookingData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test Drive Confirmed!')),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to confirm booking')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ColorSys.purple1, ColorSys.purple2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: AppBar(
            title: const Text("Test Drive Confirmation",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Car Info Card
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Car: ${widget.car.name}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Price: ₹${widget.car.totalPrice}',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Address Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Address:', style: TextStyle(fontWeight: FontWeight.bold)),
                      RadioListTile<bool>(
                        title: Text('Registered Address: $_registeredAddress'),
                        value: true,
                        groupValue: _useRegisteredAddress,
                        onChanged: (value) => setState(() => _useRegisteredAddress = value ?? true),
                      ),
                      RadioListTile<bool>(
                        title: const Text('Use Alternate Address'),
                        value: false,
                        groupValue: _useRegisteredAddress,
                        onChanged: (value) => setState(() => _useRegisteredAddress = value ?? false),
                      ),
                      if (!_useRegisteredAddress)
                        TextField(
                          controller: _alternateAddressController,
                          decoration: const InputDecoration(
                            labelText: 'Enter Alternate Address',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Date & Time Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Test Drive Date & Time:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.deepPurple),
                          const SizedBox(width: 10),
                          ElevatedButton(onPressed: _selectDate, child: const Text('Pick Date')),
                          const SizedBox(width: 10),
                          Text(_selectedDate == null
                              ? 'No date selected'
                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.deepPurple),
                          const SizedBox(width: 10),
                          ElevatedButton(onPressed: _selectTime, child: const Text('Pick Time')),
                          const SizedBox(width: 10),
                          Text(_selectedTime == null ? 'No time selected' : _selectedTime!.format(context)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorSys.purple1,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: _confirmBooking,
                  child: const Text('Confirm Test Drive', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
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
