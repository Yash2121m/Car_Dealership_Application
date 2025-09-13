import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart';

import '../Assistance/ColorHelper.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({Key? key}) : super(key: key);

  @override
  _AdminOrdersScreenState createState() => _AdminOrdersScreenState();
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

  Widget _buildSection(String title, List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ...orders.map((booking) {
          String status = booking["status"] ?? "Pending";
          return Card(
            elevation: 6,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OrderDetailScreen(bookingData: booking),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.directions_car,
                        size: 40, color: Colors.blue),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking["carName"] ?? "Unknown Car",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text("User: ${booking["userName"] ?? "N/A"}"),
                          Text("Price: ₹${booking["finalPrice"] ?? "0"}"),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(status.toUpperCase(),
                          style: const TextStyle(color: Colors.white)),
                      backgroundColor: _getStatusColor(status),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
            title: const Text("Ordered Cars",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: bookingsRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    "images/empty_box.json", // optional empty-state animation
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "No Orders Found",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          Map<dynamic, dynamic> users =
          snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          List<Map<String, dynamic>> approvedOrders = [];
          List<Map<String, dynamic>> pendingOrders = [];
          List<Map<String, dynamic>> rejectedOrders = [];

          // Collect bookings and categorize
          users.forEach((userId, userBookings) {
            if (userBookings is Map) {
              userBookings.forEach((bookingId, bookingData) {
                if (bookingData is Map) {
                  final booking = {
                    "userId": userId,
                    "bookingId": bookingId,
                    ...Map<String, dynamic>.from(bookingData),
                  };

                  String status = booking["status"]?.toString().toLowerCase() ?? "pending";
                  if (status == "approved") {
                    approvedOrders.add(booking);
                  } else if (status == "rejected") {
                    rejectedOrders.add(booking);
                  } else {
                    pendingOrders.add(booking);
                  }
                }
              });
            }
          });

          return ListView(
            children: [
              _buildSection("✅ Approved Orders", approvedOrders),
              _buildSection("⏳ Pending Orders", pendingOrders),
              _buildSection("❌ Rejected Orders", rejectedOrders),
            ],
          );
        },
      ),
    );
  }
}

class OrderDetailScreen extends StatelessWidget {
  final Map<dynamic, dynamic> bookingData;
  const OrderDetailScreen({Key? key, required this.bookingData})
      : super(key: key);

  Widget buildInfoCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              ...children]),
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
            Text("Name: ${bookingData["userName"] ?? "N/A"}"),
            Text("Email: ${bookingData["userEmail"] ?? "N/A"}"),
            Text("Phone: ${bookingData["userPhone"] ?? "N/A"}"),
          ]),
          buildInfoCard("Pricing", [
            Text("Final Price: ₹${bookingData["finalPrice"] ?? "0"}"),
            Text("Accessories: ₹${bookingData["accessoriesPrice"] ?? "0"}"),
            Text(
                "Insurance: ${bookingData["insurancePlan"] ?? "N/A"} (₹${bookingData["insurancePrice"] ?? "0"})"),
            Text(
                "Warranty: ${bookingData["warrantyPlan"] ?? "N/A"} (₹${bookingData["warrantyPrice"] ?? "0"})"),
          ]),
          buildInfoCard("Payment", [
            Text("Payment Done: ${bookingData["paymentDone"] ?? false}"),
            Text("Payment ID: ${bookingData["paymentId"] ?? "N/A"}"),
          ]),
          buildInfoCard("Order Status", [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Status: $status",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Chip(
                  label: Text(status.toUpperCase(),
                      style: const TextStyle(color: Colors.white)),
                  backgroundColor: status.toLowerCase() == "approved"
                      ? Colors.green
                      : status.toLowerCase() == "rejected"
                      ? Colors.red
                      : Colors.orange,
                ),
              ],
            ),
            Text("Order Date: ${bookingData["timestamp"] ?? "N/A"}"),
          ]),
        ],
      ),
    );
  }
}
