import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../Assistance/ColorHelper.dart';

class TestDriveHistoryPage extends StatefulWidget {
  const TestDriveHistoryPage({Key? key}) : super(key: key);

  @override
  State<TestDriveHistoryPage> createState() => _TestDriveHistoryPageState();
}

class _TestDriveHistoryPageState extends State<TestDriveHistoryPage> {
  List<Map<dynamic, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTestDriveHistory();
  }

  Future<void> _loadTestDriveHistory() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final dbRef = FirebaseDatabase.instance.ref().child('testDrive/$userId');
    final snapshot = await dbRef.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final history = data.values.map((entry) => Map<dynamic, dynamic>.from(entry)).toList();

      setState(() {
        _bookings = history.reversed.toList(); // Most recent first
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
            title: const Text("Test Drive History",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
        child: Lottie.asset(
          "images/Travel_app.json", // ✅ Your loader
          width: 250,
          height: 250,
        ),
      )
          : _bookings.isEmpty
          ? Center(
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
              "No test drives found",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _bookings.length,
        padding:
        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          final date = booking['testDriveDate'] ?? '';
          final time = booking['testDriveTime'] ?? '';
          final status = booking['status'] ?? 'pending'; // 🔹 status
          final timestamp = booking['timestamp'] != null
              ? DateFormat('dd MMM yyyy, hh:mm a')
              .format(DateTime.parse(booking['timestamp']))
              : '';

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car Name & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        booking['carName'] ?? 'Unknown Car',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      Text(
                        '₹${booking['price'] ?? '-'}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueAccent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Status chip
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text(
                        status.toUpperCase(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: status == "approved"
                          ? Colors.green.shade100
                          : status == "rejected"
                          ? Colors.red.shade100
                          : Colors.orange.shade100,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Date & Time stacked vertically
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Chip(
                        label: Text('Date: $date'),
                        backgroundColor: Colors.blue.shade50,
                      ),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text('Time: $time'),
                        backgroundColor: Colors.green.shade50,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Address
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          booking['address'] ?? 'No Address',
                          style:
                          const TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Booking Timestamp
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Booked on: $timestamp',
                        style:
                        const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
