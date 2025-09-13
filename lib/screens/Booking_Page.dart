import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../Assistance/ColorHelper.dart';
import '../Model/Car_Mode.dart';
import '../Model/user_model.dart';
import 'InsuranceWarrantyPage.dart';
import 'AccessoriesScreen.dart'; // ✅ Import Accessories Screen

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

  // ✅ Accessories state
  List<Map<String, dynamic>> selectedAccessories = [];
  int accessoriesPrice = 0;

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

  Future<void> _pickDocument(String type) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        final file = File(pickedFile.path);
        if (type == 'aadhaar') _aadhaarFile = file;
        if (type == 'pan') _panFile = file;
        if (type == 'salary') _salarySlipFile = file;
      });
    }
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
      widget.car.totalPrice + insurancePrice + warrantyPrice + accessoriesPrice;


  void _confirmBooking() async {
    final selectedAddress = _useRegisteredAddress
        ? _registeredAddress
        : _alternateAddressController.text.trim();

    if (selectedAddress.isEmpty ||
        _aadhaarFile == null ||
        _panFile == null ||
        _salarySlipFile == null ||
        _selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please complete all fields and upload all documents')),
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

    setState(() {
      _isUploading = true;
    });

    try {
      final userSnapshot = await FirebaseDatabase.instance.ref('users/$userId').get();
      if (userSnapshot.exists) {
        final userModel = UserModel.fromSnapshot(userSnapshot);

        final aadhaarBase64 = await _encodeFileToBase64(_aadhaarFile!);
        final panBase64 = await _encodeFileToBase64(_panFile!);
        final salaryBase64 = await _encodeFileToBase64(_salarySlipFile!);

        final bookingData = {
          'carName': widget.car.name,
          'basePrice': widget.car.totalPrice,
          'insurancePlan': selectedInsurance?["title"] ?? 'Not Selected',
          'insurancePrice': insurancePrice,
          'warrantyPlan': selectedWarranty?["title"] ?? 'Not Selected',
          'warrantyPrice': warrantyPrice,
          'accessories': selectedAccessories, // ✅ Store accessories
          'accessoriesPrice': accessoriesPrice,
          'finalPrice': totalPrice,
          'address': selectedAddress,
          'userName': userModel.name ?? 'Unknown User',
          'userEmail': userModel.email ?? 'No Email',
          'userPhone': userModel.phone ?? 'No Phone',
          'aadhaarBase64': aadhaarBase64,
          'panBase64': panBase64,
          'salarySlipBase64': salaryBase64,
          'selectedColor': _selectedColor!.value.toRadixString(16),
          'status': 'pending',
          'timestamp': DateTime.now().toString(),
        };

        final bookingRef = FirebaseDatabase.instance.ref().child('bookings/$userId');
        await bookingRef.push().set(bookingData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking submitted! Status: Pending')),
        );

        Navigator.pop(context);
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking failed')),
      );
    }

    setState(() {
      _isUploading = false;
    });
  }

  Widget _buildDocumentSection({
    required String label,
    required File? file,
    required VoidCallback onUpload,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.upload_file, color: Colors.blue),
        title: Text(file != null ? '$label Uploaded' : 'Upload $label'),
        trailing: file != null
            ? Icon(Icons.check_circle, color: Colors.green)
            : null,
        onTap: onUpload,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = false;

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
            title: const Text("Booking Confirmation",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car details card
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Car: ${widget.car.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Base Price: ₹ ${widget.car.totalPrice}', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Address selection
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
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

                  // Documents section
                  const Text('Upload Documents:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  _buildDocumentSection(label: 'Aadhaar', file: _aadhaarFile, onUpload: () => _pickDocument('aadhaar')),
                  _buildDocumentSection(label: 'PAN', file: _panFile, onUpload: () => _pickDocument('pan')),
                  _buildDocumentSection(label: 'Salary Slip', file: _salarySlipFile, onUpload: () => _pickDocument('salary')),
                  const SizedBox(height: 20),

                  // Insurance & Warranty
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorSys.purple1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.all(14),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InsuranceWarrantyScreen(
                            selectedInsurance: selectedInsurance,
                            selectedWarranty: selectedWarranty,
                          ),
                        ),
                      );

                      if (result != null) {
                        setState(() {
                          selectedInsurance = result["insurance"] as Map<String, String>?;
                          selectedWarranty = result["warranty"] as Map<String, String>?;
                          insurancePrice = _parsePrice(selectedInsurance?["price"]);
                          warrantyPrice = _parsePrice(selectedWarranty?["price"]);
                        });
                      }
                    },
                    child: Text(
                      (selectedInsurance == null && selectedWarranty == null) ? 'Add Insurance & Warranty' : 'Edit Insurance & Warranty',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ✅ Accessories selection button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorSys.purple1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.all(14),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AccessoriesScreen()),
                      );

                      if (result != null) {
                        setState(() {
                          selectedAccessories = List<Map<String, dynamic>>.from(result["accessories"]);
                          accessoriesPrice = result["total"] ?? 0;
                        });
                      }
                    },
                    child: Text(
                      selectedAccessories.isEmpty ? "Add Accessories" : "Edit Accessories",
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Car colour selection
                  const Text('Choose Car Colour:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Center(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: _availableColors.map((color) {
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                              border: Border.all(
                                color: isSelected ? Colors.deepPurple : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
                            ),
                            width: 55,
                            height: 55,
                            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 28) : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Final price summary card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.green[50],
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Final Price Breakdown:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text("Car Price: ₹${widget.car.totalPrice}"),
                          Text("Insurance: ₹$insurancePrice"),
                          Text("Warranty: ₹$warrantyPrice"),
                          Text("Accessories: ₹$accessoriesPrice"),
                          const Divider(),
                          Text("Total: ₹$totalPrice", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorSys.purple1,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: _confirmBooking,
                      child: const Text('Confirm Booking', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
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
