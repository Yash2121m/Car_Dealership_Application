import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart';

import '../Assistance/ColorHelper.dart';
import '../Model/Price_Formatter.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({Key? key}) : super(key: key);

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final DatabaseReference bookingsRef =
  FirebaseDatabase.instance.ref().child("bookings");

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _buildStatCard(
      String label, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.85), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 6),
            Text(
              "$count",
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(label, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style:
            const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> booking) {
    String status = booking["status"] ?? "Pending";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            _getStatusColor(status).withOpacity(0.08)
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor:
          _getStatusColor(status).withOpacity(0.15),
          child: const Icon(Icons.directions_car),
        ),
        title: Text(booking["carName"] ?? "Unknown Car"),
        subtitle: Text(
          "₹${formatIndianPrice(booking["finalPrice"])}",
        ),
        trailing: Chip(
          backgroundColor: _getStatusColor(status),
          label: Text(status.toUpperCase(),
              style: const TextStyle(color: Colors.white)),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  OrderDetailScreen(bookingData: booking),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildGradientAppBar("Ordered Cars"),
      body: StreamBuilder(
        stream: bookingsRef.onValue,
        builder:
            (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (!snapshot.hasData ||
              snapshot.data!.snapshot.value == null) {
            return Center(
              child: Lottie.asset("images/empty_box.json",
                  width: 200),
            );
          }

          Map<dynamic, dynamic> users =
          snapshot.data!.snapshot.value as Map;

          List<Map<String, dynamic>> approved = [];
          List<Map<String, dynamic>> pending = [];
          List<Map<String, dynamic>> rejected = [];

          users.forEach((userId, bookings) {
            if (bookings is Map) {
              bookings.forEach((bookingId, data) {
                if (data is Map) {
                  final booking = {
                    "userId": userId,
                    "bookingId": bookingId,
                    ...Map<String, dynamic>.from(data),
                  };

                  String status = booking["status"] ?? "pending";
                  if (status == "approved") {
                    approved.add(booking);
                  } else if (status == "rejected") {
                    rejected.add(booking);
                  } else {
                    pending.add(booking);
                  }
                }
              });
            }
          });

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _buildStatCard("Approved", approved.length,
                        Colors.green, Icons.check_circle),
                    _buildStatCard("Pending", pending.length,
                        Colors.orange, Icons.hourglass_top),
                    _buildStatCard("Rejected", rejected.length,
                        Colors.red, Icons.cancel),
                  ],
                ),
              ),
              if (approved.isNotEmpty) _buildHeader("Approved Orders"),
              ...approved.map(_buildOrderCard),
              if (pending.isNotEmpty) _buildHeader("Pending Orders"),
              ...pending.map(_buildOrderCard),
              if (rejected.isNotEmpty) _buildHeader("Rejected Orders"),
              ...rejected.map(_buildOrderCard),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildGradientAppBar(String title) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: BoxDecoration(
          gradient:
          LinearGradient(colors: [ColorSys.purple1, ColorSys.purple2]),
        ),
        child: AppBar(
          title: Text(title,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }
}

/* ================= ORDER DETAILS ================= */

class OrderDetailScreen extends StatelessWidget {
  final Map<dynamic, dynamic> bookingData;
  const OrderDetailScreen({super.key, required this.bookingData});

  // ✨ NEW: Base64 decode
  Uint8List? _decodeBase64(String? data) {
    if (data == null || data.isEmpty) return null;
    try {
      return base64Decode(data);
    } catch (_) {
      return null;
    }
  }

  // ✨ NEW: Document image widget (same UI style)
  Widget _buildDocument(
      BuildContext context, String label, String? base64Data) {
    final bytes = _decodeBase64(base64Data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
            const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        bytes != null
            ? GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    FullScreenImageViewer(imageBytes: bytes),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              bytes,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        )
            : const Text("No document uploaded",
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              ...children,
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String status = bookingData["status"] ?? "Pending";

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
            title: const Text("Ordered Details",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildInfoCard("Car Information", [
            Text("Car: ${bookingData["carName"]}"),
          ]),
          buildInfoCard("User Information", [
            Text("Name: ${bookingData["userName"]}"),
            Text("Email: ${bookingData["userEmail"]}"),
            Text("Phone: ${bookingData["userPhone"]}"),
          ]),
          buildInfoCard("Pricing", [
            Text("Final Price: ₹${bookingData["finalPrice"]}"),
            Text("Accessories: ₹${bookingData["accessoriesPrice"]}"),
            Text("Insurance: ${bookingData["insurancePlan"]}"),
            Text("Warranty: ${bookingData["warrantyPlan"]}"),
          ]),
          buildInfoCard("Order Status", [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Status: $status",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
                Chip(
                  label: Text(status.toUpperCase(),
                      style: const TextStyle(color: Colors.white)),
                  backgroundColor: status == "approved"
                      ? Colors.green
                      : status == "rejected"
                      ? Colors.red
                      : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
                "Order Date: ${formatDatePretty(bookingData["timestamp"])}"),
          ]),

          // ✨ NEW CARD — NO UI CHANGE
          buildInfoCard("Uploaded Documents", [
            _buildDocument(context, "Aadhaar",
                bookingData["aadhaarBase64"]),
            _buildDocument(context, "PAN",
                bookingData["panBase64"]),
            _buildDocument(context, "Salary Slip",
                bookingData["salarySlipBase64"]),
          ]),
        ],
      ),
    );
  }
}

/* ================= FULL SCREEN VIEW ================= */

class FullScreenImageViewer extends StatelessWidget {
  final Uint8List imageBytes;
  const FullScreenImageViewer({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Image.memory(imageBytes),
        ),
      ),
    );
  }
}
