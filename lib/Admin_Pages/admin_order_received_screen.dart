import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart'; // ✅ Import Lottie

import '../Assistance/ColorHelper.dart';

class AdminOrderReceivedScreen extends StatefulWidget {
  const AdminOrderReceivedScreen({Key? key}) : super(key: key);

  @override
  State<AdminOrderReceivedScreen> createState() => _AdminOrderReceivedScreenState();
}

class _AdminOrderReceivedScreenState extends State<AdminOrderReceivedScreen> {
  final DatabaseReference bookingsRef =
  FirebaseDatabase.instance.ref().child("bookings");
  List<Map<String, dynamic>> allBookings = [];
  bool isLoading = true; // ✅ Add loading state

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  void fetchBookings() {
    bookingsRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        setState(() {
          allBookings = [];
          isLoading = false; // ✅ Stop loading
        });
        return;
      }

      List<Map<String, dynamic>> tempList = [];

      data.forEach((userId, userBookings) {
        if (userBookings is Map) {
          userBookings.forEach((bookingId, bookingData) {
            if (bookingData["status"] == "pending") {
              tempList.add({
                "bookingId": bookingId,
                "userId": userId,
                ...Map<String, dynamic>.from(bookingData),
              });
            }
          });
        }
      });

      tempList.sort((a, b) =>
          DateTime.parse(b["timestamp"]).compareTo(DateTime.parse(a["timestamp"])));

      setState(() {
        allBookings = tempList;
        isLoading = false; // ✅ Stop loading
      });
    });
  }

  Uint8List? decodeBase64Image(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (_) {
      return null;
    }
  }

  Widget buildDocumentImage(
      BuildContext context, String label, String? base64String) {
    Uint8List? bytes = decodeBase64Image(base64String);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 5),
        bytes != null
            ? GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(bytes, fit: BoxFit.contain),
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(bytes,
                height: 120, width: double.infinity, fit: BoxFit.cover),
          ),
        )
            : const Text("No document available",
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> sendEmailNotification({
    required String userEmail,
    required String userName,
    required String carName,
    required String status,
    String reason = "",
  }) async {
    const serviceId = 'service_dzhjyg7';
    const templateId = 'template_g85kllu';
    const publicKey = '_pmkjEK3CXUmpX64a';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': publicKey,
        'template_params': {
          'to_email': userEmail,
          'user_name': userName,
          'car_name': carName,
          'order_status': status,
          'rejection_reason': reason,
        },
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email sent successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send email.")),
      );
    }
  }

  void updateBookingStatus(String userId, String bookingId, String status,
      {String reason = "", required Map<String, dynamic> booking}) {
    bookingsRef.child(userId).child(bookingId).update({
      "status": status,
      if (reason.isNotEmpty) "rejectionReason": reason,
    });

    sendEmailNotification(
      userEmail: booking["userEmail"],
      userName: booking["userName"],
      carName: booking["carName"],
      status: status,
      reason: reason,
    );
  }

  void showRejectDialog(
      BuildContext context, String userId, String bookingId, Map<String, dynamic> booking) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reject Reason"),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
              labelText: "Enter reason for rejection",
              border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              updateBookingStatus(
                userId,
                bookingId,
                "rejected",
                reason: reasonController.text,
                booking: booking,
              );
              Navigator.pop(context);
            },
            child: const Text("Reject"),
          ),
        ],
      ),
    );
  }

  Widget statusBadge(String status) {
    Color color = Colors.orange;
    if (status == "approved") color = Colors.green;
    if (status == "rejected") color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12)),
      child: Text(status.toUpperCase(),
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
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
            title: const Text("Orders Received",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: isLoading
          ? Center(
        child: Lottie.asset(
          "images/Travel_app.json", // ✅ Your loader
          width: 250,
          height: 250,
        ),
      )
          : allBookings.isEmpty
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
                "No Pending Orders Found",
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
        itemCount: allBookings.length,
        itemBuilder: (context, index) {
          final booking = allBookings[index];

          return ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            collapsedBackgroundColor: Colors.white,
            backgroundColor: Colors.white,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: ColorSys.purple2,
                  child: Text(
                    booking["userName"][0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    booking["carName"],
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                statusBadge(booking["status"]),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("👤 ${booking["userName"]}"),
                      Text("📧 ${booking["userEmail"]}"),
                      Text("📞 ${booking["userPhone"]}"),
                      Text("🏠 ${booking["address"]}"),
                      Text("💰 Price: ₹${booking["finalPrice"]}"),
                      Text("🎨 Color: ${getColorName(booking["selectedColor"])}"),
                      const SizedBox(height: 12),
                      buildDocumentImage(context, "Aadhaar", booking["aadhaarBase64"]),
                      buildDocumentImage(context, "PAN", booking["panBase64"]),
                      buildDocumentImage(context, "Salary Slip", booking["salarySlipBase64"]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            onPressed: () {
                              updateBookingStatus(
                                booking["userId"],
                                booking["bookingId"],
                                "approved",
                                booking: booking,
                              );
                            },
                            icon: const Icon(Icons.check),
                            label: const Text("Approve"),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            onPressed: () {
                              showRejectDialog(context, booking["userId"],
                                  booking["bookingId"], booking);
                            },
                            icon: const Icon(Icons.close),
                            label: const Text("Reject"),
                          ),
                        ],
                      )
                    ]),
              )
            ],
          );
        },
      ),
    );
  }
}

String getColorName(String hex) {
  if (hex.length == 8) {
    hex = hex.substring(2);
  }

  final colorNames = {
    "f44336": "Red",
    "e91e63": "Pink",
    "9c27b0": "Purple",
    "673ab7": "Deep Purple",
    "3f51b5": "Indigo",
    "2196f3": "Blue",
    "03a9f4": "Light Blue",
    "00bcd4": "Cyan",
    "009688": "Teal",
    "4caf50": "Green",
    "8bc34a": "Light Green",
    "cddc39": "Lime",
    "ffeb3b": "Yellow",
    "ffc107": "Amber",
    "ff9800": "Orange",
    "ff5722": "Deep Orange",
    "795548": "Brown",
    "9e9e9e": "Grey",
    "607d8b": "Blue Grey",
    "000000": "Black",
    "ffffff": "White",
  };

  return colorNames[hex.toLowerCase()] ?? "#$hex";
}