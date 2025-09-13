import 'dart:ui';
import 'package:cardealer/Assistance/ColorHelper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart'; // ✅ Added
import '../Model/Car.dart';
import '../Model/Car_Mode.dart';
import 'BookingDetailScreen.dart';
import 'package:collection/collection.dart';

class OrderedCarScreen extends StatefulWidget {
  const OrderedCarScreen({Key? key}) : super(key: key);

  @override
  _OrderedCarScreenState createState() => _OrderedCarScreenState();
}

class _OrderedCarScreenState extends State<OrderedCarScreen> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  List<Map<dynamic, dynamic>> normalBookings = [];
  List<Map<dynamic, dynamic>> emiBookings = [];
  bool isLoading = true; // ✅ Added

  @override
  void initState() {
    super.initState();
    fetchAllBookings();
  }

  void fetchAllBookings() async {
    if (uid == null) return;

    setState(() => isLoading = true); // show loader

    // Normal Bookings
    final normalSnap = await _dbRef.child('bookings').child(uid!).get();
    if (normalSnap.exists) {
      final Map<dynamic, dynamic> data = normalSnap.value as Map;
      data.forEach((key, value) {
        final booking = value as Map;
        booking['bookingId'] = key;
        booking['isEmi'] = false;
        normalBookings.add(booking);
      });
    }

    // EMI Bookings
    final emiSnap = await _dbRef.child('EMI_Bookings').child(uid!).get();
    if (emiSnap.exists) {
      final Map<dynamic, dynamic> data = emiSnap.value as Map;
      data.forEach((key, value) {
        final booking = value as Map;
        booking['bookingId'] = key;
        booking['isEmi'] = true;
        emiBookings.add(booking);
      });
    }

    setState(() => isLoading = false); // hide loader
  }

  String? getCarImage(String carName) {
    List<Car> allCars = sedanCars + suvCars + Coupe + Hatchback + Convertible;
    final car = allCars.firstWhereOrNull((c) => c.name == carName);
    return car?.images.isNotEmpty == true ? car!.images[0] : null;
  }

  Widget buildSection(String title, List<Map<dynamic, dynamic>> bookings, bool isEmi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        bookings.isEmpty
            ? Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.car_crash, size: 60, color: Colors.grey),
              const SizedBox(height: 10),
              Text("No $title found.",
                  style: const TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        )
            : Column(
          children: List.generate(bookings.length, (index) {
            final booking = bookings[index];
            final carName =
                booking['car_name'] ?? booking['carName'] ?? 'Unknown';
            final imagePath = getCarImage(carName);
            final status =
                booking['status']?.toString().toLowerCase() ?? 'pending';

            Color statusColor;
            switch (status) {
              case 'approved':
                statusColor = Colors.green;
                break;
              case 'rejected':
                statusColor = Colors.red;
                break;
              default:
                statusColor = Colors.orange;
            }

            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              margin:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Hero(
                  tag: "carImage_$index$title",
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imagePath != null
                        ? Image.asset(imagePath,
                        height: 60, width: 90, fit: BoxFit.cover)
                        : const Icon(Icons.directions_car, size: 40),
                  ),
                ),
                title: Text(carName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: isEmi
                    ? Text(
                  "EMI: ₹${booking['monthly_emi'] ?? '-'}\nTotal: ₹${booking['total_amount_payable'] ?? '-'}",
                  style: const TextStyle(fontSize: 14),
                )
                    : Text(
                  "Price: ₹${booking['finalPrice'] ?? '-'}",
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: Chip(
                  label: Text(status.toUpperCase(),
                      style: const TextStyle(color: Colors.white)),
                  backgroundColor: statusColor,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration:
                      const Duration(milliseconds: 500),
                      pageBuilder:
                          (context, animation, secondaryAnimation) =>
                          BookingDetailScreen(
                            bookingData: booking,
                            isEmi: isEmi,
                            imagePath: imagePath,
                            bookingId: booking['bookingId'],
                          ),
                      transitionsBuilder: (context, animation,
                          secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = false;

    return Scaffold(
      backgroundColor: darkTheme? Colors.black:ColorSys.carback,
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
            title: const Text("My Orders",
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
          : SingleChildScrollView(
        child: Column(
          children: [
            normalBookings.isEmpty
                ? SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
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
                      "No Orders found",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : buildSection("Normal Bookings", normalBookings, false),
            emiBookings.isEmpty
                ? const SizedBox()
                : buildSection("EMI Bookings", emiBookings, true),
          ],
        ),
      ),
    );
  }
}
