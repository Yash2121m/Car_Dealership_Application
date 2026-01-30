import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../Assistance/ColorHelper.dart';
import '../Model/Price_Formatter.dart';
import '../global/global.dart';
import '../screens/login_screen.dart';

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

    // 🚫 Block guest users
    if (isGuest || FirebaseAuth.instance.currentUser == null) {
      _isLoading = false;
      return;
    }

    _loadTestDriveHistory();
  }

  Future<void> _loadTestDriveHistory() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final dbRef = FirebaseDatabase.instance.ref().child('testDrive/$userId');
    final snapshot = await dbRef.get();

    if (snapshot.exists) {
      final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
      final history =
      data.values.map((e) => Map<dynamic, dynamic>.from(e)).toList();

      setState(() {
        _bookings = history.reversed.toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
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
            title: const Text(
              "Test Drive History",
              style:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
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
            const Text(
              "Login Required",
              style:
              TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please login to view test drive history",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorSys.purple1,
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 12),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
              child: const Text(
                "Go to Login",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      )
          : _isLoading
          ? Center(
        child: Lottie.asset(
          "images/Travel_app.json",
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
              "images/empty_box.json",
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 12),
            const Text(
              "No test drives found",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _bookings.length,
        padding: const EdgeInsets.symmetric(
            vertical: 8, horizontal: 12),
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          final status =
              booking['status']?.toString().toLowerCase() ??
                  'pending';

          Color chipColor;
          switch (status) {
            case 'approved':
              chipColor = Colors.green.shade100;
              break;
            case 'rejected':
              chipColor = Colors.red.shade100;
              break;
            default:
              chipColor = Colors.orange.shade100;
          }

          final timestamp = booking['timestamp'] != null
              ? DateFormat('dd MMM yyyy, hh:mm a').format(
            DateTime.parse(booking['timestamp']),
          )
              : '';

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        booking['carName'] ?? 'Unknown Car',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '₹${booking['price'] ?? '-'}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blueAccent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      status.toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: chipColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                      'Date: ${formatDatePretty(booking['testDriveDate']) ?? '-'}'),
                  Text(
                      'Time: ${booking['testDriveTime'] ?? '-'}'),
                  const SizedBox(height: 6),
                  Text(
                    booking['address'] ?? 'No Address',
                    style:
                    const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Booked on: $timestamp',
                    style:
                    const TextStyle(color: Colors.black54),
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
