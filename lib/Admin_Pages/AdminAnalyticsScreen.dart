import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

import '../Assistance/ColorHelper.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final DatabaseReference bookingsRef =
  FirebaseDatabase.instance.ref().child("bookings");

  int totalOrders = 0;
  int approvedOrders = 0;
  int pendingOrders = 0;
  int rejectedOrders = 0;
  double totalRevenue = 0;
  double accessoriesRevenue = 0; // 👈 NEW

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  void fetchAnalytics() {
    bookingsRef.onValue.listen((event) {
      if (event.snapshot.value == null) return;

      Map<dynamic, dynamic> users =
      event.snapshot.value as Map<dynamic, dynamic>;

      int approved = 0, pending = 0, rejected = 0;
      double revenue = 0;
      double accessories = 0;
      int total = 0;

      users.forEach((userId, userBookings) {
        if (userBookings is Map) {
          userBookings.forEach((bookingId, bookingData) {
            if (bookingData is Map) {
              total++;
              String status =
                  bookingData["status"]?.toString().toLowerCase() ?? "pending";

              if (status == "approved") {
                approved++;

                // Car revenue
                revenue += double.tryParse(
                    bookingData["finalPrice"]?.toString() ?? "0") ??
                    0;

                // Accessories revenue 👇
                if (bookingData["accessories"] is List) {
                  for (var acc in bookingData["accessories"]) {
                    if (acc is Map) {
                      accessories += double.tryParse(
                          acc["price"]?.toString() ?? "0") ??
                          0;
                    }
                  }
                }
              } else if (status == "rejected") {
                rejected++;
              } else {
                pending++;
              }
            }
          });
        }
      });

      setState(() {
        totalOrders = total;
        approvedOrders = approved;
        pendingOrders = pending;
        rejectedOrders = rejected;
        totalRevenue = revenue;
        accessoriesRevenue = accessories;
      });
    });
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
            title: const Text("Sales Analytics",
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
          _buildStatCard("Total Orders", totalOrders.toString(), Colors.blue),
          _buildStatCard("Approved Orders", approvedOrders.toString(), Colors.green),
          _buildStatCard("Pending Orders", pendingOrders.toString(), Colors.orange),
          _buildStatCard("Rejected Orders", rejectedOrders.toString(), Colors.red),
          _buildStatCard("Total Revenue", "₹${totalRevenue.toStringAsFixed(2)}", Colors.purple),

          // 👇 New Accessories Card
          _buildStatCard("Accessories Revenue", "₹${accessoriesRevenue.toStringAsFixed(2)}", Colors.teal),

          const SizedBox(height: 20),

          // Pie Chart
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text("Orders Distribution",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 200,
                    child: _OrdersPieChart(
                      approved: approvedOrders,
                      pending: pendingOrders,
                      rejected: rejectedOrders,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.bar_chart, color: color),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        trailing: Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: color)),
      ),
    );
  }
}

class _OrdersPieChart extends StatelessWidget {
  final int approved;
  final int pending;
  final int rejected;

  const _OrdersPieChart({
    Key? key,
    required this.approved,
    required this.pending,
    required this.rejected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            value: approved.toDouble(),
            color: Colors.green,
            title: "Approved",
            radius: 60,
          ),
          PieChartSectionData(
            value: pending.toDouble(),
            color: Colors.orange,
            title: "Pending",
            radius: 60,
          ),
          PieChartSectionData(
            value: rejected.toDouble(),
            color: Colors.red,
            title: "Rejected",
            radius: 60,
          ),
        ],
      ),
    );
  }
}

