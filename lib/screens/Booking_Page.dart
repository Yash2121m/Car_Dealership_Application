import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Model/Car_Mode.dart';
import '../Model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingPage extends StatefulWidget {
  final Car car;

  const BookingPage({Key? key, required this.car}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _alternateAddressController = TextEditingController();
  bool _useRegisteredAddress = true;
  String _registeredAddress = 'Loading...';

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
    } catch (error) {
      setState(() {
        _registeredAddress = 'Error fetching address';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Car: ${widget.car.name}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Price: ₹ ${widget.car.totalPrice}',
              style: TextStyle(fontSize: 18, color: darkTheme ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 30),
            const Text(
              'Select Address:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            RadioListTile<bool>(
              title: Text('Registered Address: $_registeredAddress'),
              value: true,
              groupValue: _useRegisteredAddress,
              onChanged: (value) {
                setState(() {
                  _useRegisteredAddress = value ?? true;
                });
              },
            ),
            RadioListTile<bool>(
              title: const Text('Use Alternate Address'),
              value: false,
              groupValue: _useRegisteredAddress,
              onChanged: (value) {
                setState(() {
                  _useRegisteredAddress = value ?? false;
                });
              },
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
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _confirmBooking,
                child: const Text('Confirm Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmBooking() async {
    final selectedAddress = _useRegisteredAddress
        ? _registeredAddress
        : _alternateAddressController.text.trim();

    if (selectedAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide an address')),
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

    final dbRef = FirebaseDatabase.instance.ref().child('users/$userId');

    try {
      // Fetch user profile data
      final snapshot = await dbRef.get();
      if (snapshot.exists) {
        final userModel = UserModel.fromSnapshot(snapshot);

        // Prepare booking data
        final bookingData = {
          'carName': widget.car.name,
          'price': widget.car.totalPrice,
          'address': selectedAddress,
          'userName': userModel.name ?? 'Unknown User',
          'userEmail': userModel.email ?? 'No Email',
          'userPhone': userModel.phone ?? 'No Phone',
          'timestamp': DateTime.now().toString(),
        };

        // Save booking data under 'bookings' node in Firebase
        final bookingRef = FirebaseDatabase.instance.ref().child('bookings/$userId');
        await bookingRef.push().set(bookingData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking Confirmed!')),
        );

        // Navigate back or to another screen
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch user data')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to confirm booking')),
      );
    }
  }



  @override
  void dispose() {
    _alternateAddressController.dispose();
    super.dispose();
  }
}
