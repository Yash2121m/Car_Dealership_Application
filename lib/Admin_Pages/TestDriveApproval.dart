import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../Assistance/ColorHelper.dart';

class AdminTestDriveApprovalScreen extends StatefulWidget {
  const AdminTestDriveApprovalScreen({Key? key}) : super(key: key);

  @override
  State<AdminTestDriveApprovalScreen> createState() =>
      _AdminTestDriveApprovalScreenState();
}

class _AdminTestDriveApprovalScreenState
    extends State<AdminTestDriveApprovalScreen> {
  final DatabaseReference _testDriveRef =
  FirebaseDatabase.instance.ref("testDrive");

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
              ),
            ],
          ),
          child: AppBar(
            title: const Text("Test Drive Approvals",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),

      body: StreamBuilder(
        stream: _testDriveRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // ✅ Show Lottie loader while loading
            return Center(
              child: Lottie.asset(
                "images/Travel_app.json",
                width: 250,
                height: 250,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            // ✅ Show empty message when no test drives exist
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
                    "No test drive requests found",
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

          // 🔹 rest of your logic stays the same

          Map<dynamic, dynamic> allData =
          snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          List<Map<String, dynamic>> requests = [];

          allData.forEach((userId, bookings) {
            (bookings as Map).forEach((bookingId, details) {
              requests.add({
                "userId": userId,
                "bookingId": bookingId,
                ...Map<String, dynamic>.from(details),
              });
            });
          });

          // Sort by latest request
          requests.sort((a, b) => DateTime.parse(b['timestamp'])
              .compareTo(DateTime.parse(a['timestamp'])));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final status = request['status'] ?? "pending";

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                elevation: 6,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Car Name + Status Chip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            request['carName'] ?? "Unknown Car",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Chip(
                            label: Text(
                              status.toUpperCase(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            backgroundColor: status == "approved"
                                ? Colors.green.shade100
                                : status == "rejected"
                                ? Colors.red.shade100
                                : Colors.orange.shade100,
                          )
                        ],
                      ),

                      const SizedBox(height: 8),
                      Text("Price: ₹${request['price']}",
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.blueAccent)),

                      const Divider(height: 20, thickness: 1),

                      // Customer Info
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.purple),
                          const SizedBox(width: 6),
                          Expanded(
                              child: Text(request['userName'] ?? "Unknown")),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.email, color: Colors.teal),
                          const SizedBox(width: 6),
                          Expanded(
                              child: Text(request['userEmail'] ?? "No email")),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.indigo),
                          const SizedBox(width: 6),
                          Expanded(
                              child: Text(request['userPhone'] ?? "No phone")),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red),
                          const SizedBox(width: 6),
                          Expanded(
                              child: Text(request['address'] ?? "No Address")),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Date & Time Row
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 18, color: Colors.blueGrey),
                          const SizedBox(width: 6),
                          Text("${request['testDriveDate']}"),
                          const SizedBox(width: 12),
                          const Icon(Icons.access_time,
                              size: 18, color: Colors.blueGrey),
                          const SizedBox(width: 6),
                          Text("${request['testDriveTime']}"),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Approve / Reject Buttons
                      if (status == "pending")
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => _updateStatus(
                                    request['userId'],
                                    request['bookingId'],
                                    "approved"),
                                icon: const Icon(Icons.check),
                                label: const Text("Approve"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => _updateStatus(
                                    request['userId'],
                                    request['bookingId'],
                                    "rejected"),
                                icon: const Icon(Icons.close),
                                label: const Text("Reject"),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _updateStatus(
      String userId, String bookingId, String status) async {
    try {
      await _testDriveRef
          .child(userId)
          .child(bookingId)
          .update({"status": status});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Test Drive $status")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update status")),
      );
    }
  }
}
