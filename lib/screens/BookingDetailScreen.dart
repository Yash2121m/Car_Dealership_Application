import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cardealer/Assistance/ColorHelper.dart';
import 'package:cardealer/screens/full_image_screen.dart';
import 'package:lottie/lottie.dart';
import 'PaymentScreen.dart';

class BookingDetailScreen extends StatefulWidget {
  final Map<dynamic, dynamic> bookingData;
  final bool isEmi;
  final String? imagePath;
  final String bookingId;

  const BookingDetailScreen({
    Key? key,
    required this.bookingData,
    required this.isEmi,
    required this.imagePath,
    required this.bookingId,
  }) : super(key: key);

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  Map<dynamic, dynamic>? bookingData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final ref = FirebaseDatabase.instance
        .ref()
        .child("bookings")
        .child(userId)         // 👈 include userId
        .child(widget.bookingId);

    final snapshot = await ref.get();

    if (snapshot.exists) {
      setState(() {
        bookingData = snapshot.value as Map<dynamic, dynamic>;
        isLoading = false;
      });
    } else {
      setState(() {
        bookingData = widget.bookingData; // fallback
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    bool darkTheme = false;

    if (isLoading || bookingData == null) {
      return Scaffold(
        body: Center(
          child: Lottie.asset(
            "images/Travel_app.json", // ✅ Your loader
            width: 250,
            height: 250,
          ),
        ),
      );
    }

    final String? aadhaarBase64 = bookingData!['aadhaarBase64'];
    final String? panBase64 = bookingData!['panBase64'];
    final String? salarySlipBase64 = bookingData!['salarySlipBase64'];
    final String orderStatus = bookingData!['status'] ?? 'Pending';
    final bool isPaymentDone = bookingData!['paymentDone'] == true;

    return Scaffold(
      backgroundColor: ColorSys.carback,
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
            title: const Text("Booking Details",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            if (widget.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(widget.imagePath!,
                    height: 160, fit: BoxFit.cover),
              ),

            const SizedBox(height: 10),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: darkTheme? Colors.black87 : ColorSys.purple1,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _statusTile(orderStatus),
                      const SizedBox(height: 20),

                      const Text("Booking Info",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      _infoRow("Booking ID", widget.bookingId),
                      _infoRow("Name of Owner",
                          bookingData!['userName'] ?? 'Unknown'),
                      _infoRow(
                          "Car Name",
                          bookingData!['car_name'] ??
                              bookingData!['carName'] ??
                              'Unknown'),

                      if (widget.isEmi) ...[
                        _infoRow("Monthly EMI",
                            "₹${bookingData!['monthly_emi'] ?? '-'}"),
                        _infoRow("Tenure",
                            "${bookingData!['tenure_months'] ?? '-'} months"),
                        _infoRow("Interest Rate",
                            "${bookingData!['interest_rate'] ?? '-'}%"),
                        _infoRow("Total Amount Payable",
                            "₹${bookingData!['total_amount_payable'] ?? '-'}"),
                      ] else ...[
                        _infoRow("Price",
                            "₹${bookingData!['finalPrice'] ?? '-'}"),
                        _infoRow("Address", bookingData!['address'] ?? '-'),
                      ],

                      const SizedBox(height: 20),

                      const Text("Uploaded Documents",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),

                      if (aadhaarBase64 != null && aadhaarBase64.isNotEmpty)
                        _buildBase64Image("Aadhaar", aadhaarBase64, context),
                      if (panBase64 != null && panBase64.isNotEmpty)
                        _buildBase64Image("PAN", panBase64, context),
                      if (salarySlipBase64 != null &&
                          salarySlipBase64.isNotEmpty)
                        _buildBase64Image(
                            "Salary Slip", salarySlipBase64, context),

                      if ((aadhaarBase64 == null || aadhaarBase64.isEmpty) &&
                          (panBase64 == null || panBase64.isEmpty) &&
                          (salarySlipBase64 == null ||
                              salarySlipBase64.isEmpty))
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text("No documents uploaded.",
                              style: TextStyle(color: Colors.black54)),
                        ),

                      const SizedBox(height: 20),

                      if (orderStatus.toLowerCase() == 'approved' && !isPaymentDone)
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              int priceInPaise = 10000;
                              try {
                                priceInPaise =
                                    int.parse(bookingData!['finalPrice'].toString()) * 100;
                              } catch (_) {}

                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PaymentScreen(
                                    bookingData: bookingData!,
                                    amount: priceInPaise,
                                    bookingId: widget.bookingId,
                                  ),
                                ),
                              );

                              if (result == true) {
                                _loadBooking(); // reload Firebase booking
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorSys.purple2,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                            ),
                            child: const Text(
                              "Pay Now",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusTile(String status) {
    Color statusColor = status.toLowerCase() == 'approved'
        ? Colors.green
        : status.toLowerCase() == 'rejected'
        ? Colors.red
        : Colors.orange;

    return Row(
      children: [
        const Text("Order Status: ",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(
          status,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: statusColor),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildBase64Image(
      String label, String base64String, BuildContext context) {
    try {
      Uint8List imageBytes = base64Decode(base64String);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      FullImageScreen(imageBytes: imageBytes, label: label),
                ),
              );
            },
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  imageBytes,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      );
    } catch (e) {
      return Text("Error loading $label image");
    }
  }
}
