import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../Assistance/ColorHelper.dart';
import '../Model/Car_Mode.dart';
import '../Model/user_model.dart';
import '../global/global.dart';
import '../screens/login_screen.dart';
import 'InsuranceWarrantyPage.dart';
import 'AccessoriesScreen.dart';

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

  File? _aadhaarFile;
  File? _panFile;
  File? _salarySlipFile;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  final List<Color> _availableColors = [
    Colors.red,
    Colors.blue,
    Colors.black,
    Colors.white,
    Colors.grey,
    Colors.green,
    Colors.yellow,
  ];
  Color? _selectedColor;

  Map<String, String>? selectedInsurance;
  Map<String, String>? selectedWarranty;
  int insurancePrice = 0;
  int warrantyPrice = 0;

  List<Map<String, dynamic>> selectedAccessories = [];
  int accessoriesPrice = 0;

  @override
  void initState() {
    super.initState();

    // 🚫 Guest users cannot book
    if (isGuest || FirebaseAuth.instance.currentUser == null) {
      return;
    }

    _fetchRegisteredAddress();
  }

  Future<void> _fetchRegisteredAddress() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final dbRef = FirebaseDatabase.instance.ref().child('users/$userId');
    final snapshot = await dbRef.get();

    if (snapshot.exists) {
      final userModel = UserModel.fromSnapshot(snapshot);
      setState(() {
        _registeredAddress = userModel.address ?? 'No address found';
      });
    }
  }

  Future<void> _pickDocument(String type) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    setState(() {
      if (type == 'aadhaar') _aadhaarFile = file;
      if (type == 'pan') _panFile = file;
      if (type == 'salary') _salarySlipFile = file;
    });
  }

  Future<String> _encodeFileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  int _parsePrice(String? priceStr) {
    if (priceStr == null) return 0;
    return int.tryParse(priceStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  double get totalPrice =>
      widget.car.totalPrice +
          insurancePrice +
          warrantyPrice +
          accessoriesPrice;

  void _confirmBooking() async {
    if (isGuest) return;

    final selectedAddress = _useRegisteredAddress
        ? _registeredAddress
        : _alternateAddressController.text.trim();

    if (selectedAddress.isEmpty ||
        _aadhaarFile == null ||
        _panFile == null ||
        _salarySlipFile == null ||
        _selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isUploading = true);

    try {
      final userSnapshot =
      await FirebaseDatabase.instance.ref('users/$userId').get();
      if (!userSnapshot.exists) return;

      final userModel = UserModel.fromSnapshot(userSnapshot);

      final bookingData = {
        'carName': widget.car.name,
        'basePrice': widget.car.totalPrice,
        'insurancePlan': selectedInsurance?["title"] ?? 'Not Selected',
        'insurancePrice': insurancePrice,
        'warrantyPlan': selectedWarranty?["title"] ?? 'Not Selected',
        'warrantyPrice': warrantyPrice,
        'accessories': selectedAccessories,
        'accessoriesPrice': accessoriesPrice,
        'finalPrice': totalPrice,
        'address': selectedAddress,
        'userName': userModel.name ?? '',
        'userEmail': userModel.email ?? '',
        'userPhone': userModel.phone ?? '',
        'aadhaarBase64': await _encodeFileToBase64(_aadhaarFile!),
        'panBase64': await _encodeFileToBase64(_panFile!),
        'salarySlipBase64': await _encodeFileToBase64(_salarySlipFile!),
        'selectedColor': _selectedColor!.value.toRadixString(16),
        'status': 'pending',
        'timestamp': DateTime.now().toString(),
      };

      await FirebaseDatabase.instance
          .ref('bookings/$userId')
          .push()
          .set(bookingData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking submitted successfully')),
      );

      Navigator.pop(context);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Widget _buildDocumentTile(String label, File? file, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.upload_file),
        title: Text(file != null ? '$label uploaded' : 'Upload $label'),
        trailing:
        file != null ? const Icon(Icons.check, color: Colors.green) : null,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Confirmation"),
        backgroundColor: ColorSys.purple2,
      ),

      /// ---------------- GUEST GUARD ----------------
      body: isGuest || FirebaseAuth.instance.currentUser == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline,
                size: 80, color: Colors.grey),
            const SizedBox(height: 15),
            const Text("Login Required",
                style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Please login to book a car"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: ColorSys.purple1),
              child: const Text("Go to Login"),
            ),
          ],
        ),
      )
          : Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.car.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Base Price: ₹${widget.car.totalPrice}"),
                const SizedBox(height: 20),

                _buildDocumentTile(
                    "Aadhaar", _aadhaarFile, () => _pickDocument('aadhaar')),
                _buildDocumentTile(
                    "PAN", _panFile, () => _pickDocument('pan')),
                _buildDocumentTile("Salary Slip", _salarySlipFile,
                        () => _pickDocument('salary')),

                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _confirmBooking,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: ColorSys.purple1),
                    child: const Text("Confirm Booking"),
                  ),
                ),
              ],
            ),
          ),
          if (_isUploading)
            Container(
              color: Colors.black54,
              child: const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _alternateAddressController.dispose();
    super.dispose();
  }
}
