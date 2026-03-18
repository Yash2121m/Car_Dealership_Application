import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import '../Assistance/ColorHelper.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';


class AdminOrderReceivedScreen extends StatefulWidget {
  const AdminOrderReceivedScreen({Key? key}) : super(key: key);

  @override
  State<AdminOrderReceivedScreen> createState() => _AdminOrderReceivedScreenState();
}

class _AdminOrderReceivedScreenState extends State<AdminOrderReceivedScreen> {
  final DatabaseReference bookingsRef =
  FirebaseDatabase.instance.ref().child("bookings");
  List<Map<String, dynamic>> allBookings = [];
  bool isLoading = true;

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
          isLoading = false;
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
        isLoading = false;
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

  Future<void> exportBookingPdf(Map<String, dynamic> booking) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.notoSansRegular();

    final logoBytes = await rootBundle.load('images/logo3.png');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(base: font),
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      pw.Image(logo, width: 60, height: 60),
                      pw.SizedBox(width: 10),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "AutoVerse",
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue,
                            ),
                          ),
                          pw.Text(
                            "Car Booking System",
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  pw.Text(
                    "BOOKING REPORT",
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 10),
              pw.Divider(),

              pw.SizedBox(height: 10),
              pw.Text(
                "Car Booking Report",
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Text(
                "Customer Details",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey800,
                ),
              ),
              pw.SizedBox(height: 8),

              _pdfRow("Name", booking["userName"]),
              _pdfRow("Email", booking["userEmail"]),
              _pdfRow("Phone", booking["userPhone"]),
              _pdfRow("Address", booking["address"]),

              pw.Divider(height: 25),

              pw.Text(
                "Car Details",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey800,
                ),
              ),
              pw.SizedBox(height: 8),

              _pdfRow("Car Name", booking["carName"]),
              _pdfRow("Selected Color", getColorName(booking["selectedColor"])),
              _pdfRow("Final Price", "₹${booking["finalPrice"]}"),
              _pdfRow(
                "Status",
                booking["status"].toUpperCase(),
              ),

              pw.Divider(height: 25),

              _pdfRow(
                "Booking Date",
                DateTime.parse(booking["timestamp"])
                    .toLocal()
                    .toString(),
              ),

              pw.Spacer(),

              pw.Center(
                child: pw.Text(
                  "Generated by AutoVerse Admin Panel • ${DateTime.now().toString().substring(0, 10)}",
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _pdfRow(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 120,
            child: pw.Text(
              title,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }


  Widget buildDocumentImage(
      BuildContext context, String label, String? base64String) {
    Uint8List? bytes = decodeBase64Image(base64String);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 6),
        bytes != null
            ? GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenImageViewer(imageBytes: bytes),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Image.memory(
                  bytes,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.zoom_in,
                        color: Colors.white, size: 18),
                  ),
                )
              ],
            ),
          ),
        )
            : const Text("No document uploaded",
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

  void confirmApprove(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Approve Order"),
        content: const Text("Are you sure you want to approve this order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(context);
              updateBookingStatus(
                booking["userId"],
                booking["bookingId"],
                "approved",
                booking: booking,
              );
            },
            child: const Text("Approve"),
          ),
        ],
      ),
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
          "images/Travel_app.json",
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
                "images/empty_box.json",
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking["carName"],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        booking["userName"],
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                statusBadge(booking["status"]),
              ],
            ),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () => exportBookingPdf(booking),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Export PDF"),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () => confirmApprove(booking),
                    icon: const Icon(Icons.check),
                    label: const Text("Approve"),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {
                      showRejectDialog(
                        context,
                        booking["userId"],
                        booking["bookingId"],
                        booking,
                      );
                    },
                    icon: const Icon(Icons.close),
                    label: const Text("Reject"),
                  ),
                ],
              ),

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
                      const SizedBox(height: 8),
                      const Divider(height: 24, thickness: 1),
                      const Text(
                        "Uploaded Documents",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

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
                            onPressed: () => confirmApprove(booking),
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


class FullScreenImageViewer extends StatelessWidget {
  final Uint8List imageBytes;

  const FullScreenImageViewer({Key? key, required this.imageBytes})
      : super(key: key);

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
          panEnabled: true,
          child: Image.memory(imageBytes),
        ),
      ),
    );
  }
}
