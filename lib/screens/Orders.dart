import 'dart:ui';
import 'package:cardealer/Assistance/ColorHelper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart';
import 'package:collection/collection.dart';

import '../Model/Car.dart';
import '../Model/Car_Mode.dart';
import '../Model/Price_Formatter.dart';
import '../global/global.dart';
import '../screens/login_screen.dart';
import 'BookingDetailScreen.dart';

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

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // 🚫 Block guest users
    if (isGuest || uid == null) {
      isLoading = false;
      return;
    }

    fetchAllBookings();
  }

  /// ---------------- FETCH BOOKINGS ----------------
  void fetchAllBookings() async {
    setState(() => isLoading = true);

    normalBookings.clear();
    emiBookings.clear();

    // NORMAL BOOKINGS
    final normalSnap = await _dbRef.child('bookings').child(uid!).get();
    if (normalSnap.exists) {
      final Map<dynamic, dynamic> data =
      normalSnap.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        final booking = Map<dynamic, dynamic>.from(value);
        booking['bookingId'] = key;
        booking['isEmi'] = false;
        normalBookings.add(booking);
      });
    }

    // EMI BOOKINGS
    final emiSnap = await _dbRef.child('EMI_Bookings').child(uid!).get();
    if (emiSnap.exists) {
      final Map<dynamic, dynamic> data =
      emiSnap.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        final booking = Map<dynamic, dynamic>.from(value);
        booking['bookingId'] = key;
        booking['isEmi'] = true;
        emiBookings.add(booking);
      });
    }

    setState(() => isLoading = false);
  }

  /// ---------------- CAR IMAGE ----------------
  String? getCarImage(String carName) {
    List<Car> allCars =
        sedanCars + suvCars + Coupe + Hatchback + Convertible;
    final car = allCars.firstWhereOrNull((c) => c.name == carName);
    return car?.images.isNotEmpty == true ? car!.images.first : null;
  }

  /// ---------------- BOOKING SECTION ----------------
  Widget buildSection(
      String title, List<Map<dynamic, dynamic>> bookings, bool isEmi) {
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
            children: const [
              Icon(Icons.car_crash, size: 60, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                "No bookings found",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
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
              margin: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imagePath != null
                      ? Image.asset(imagePath,
                      height: 60, width: 90, fit: BoxFit.cover)
                      : const Icon(Icons.directions_car, size: 40),
                ),
                title: Text(
                  carName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: isEmi
                    ? Text(
                  "EMI: ₹${booking['monthly_emi'] ?? '-'}\nTotal: ₹${booking['total_amount_payable'] ?? '-'}",
                )
                    : Text(
                  "Price: ₹${formatIndianPrice(booking['finalPrice']) ?? '-'}",
                ),
                trailing: Chip(
                  backgroundColor: statusColor,
                  label: Text(
                    status.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingDetailScreen(
                        bookingData: booking,
                        isEmi: isEmi,
                        imagePath: imagePath,
                        bookingId: booking['bookingId'],
                      ),
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
      backgroundColor: darkTheme ? Colors.black : ColorSys.carback,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient:
            LinearGradient(colors: [ColorSys.purple1, ColorSys.purple2]),
            borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: AppBar(
            title: const Text(
              "My Orders",
              style:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),

      /// ---------------- BODY ----------------
      body: isGuest || uid == null
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
              "Please login to view your orders",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorSys.purple2,
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
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
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      )
          : isLoading
          ? Center(
        child: Lottie.asset(
          "images/Travel_app.json",
          width: 250,
          height: 250,
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            buildSection(
                "Normal Bookings", normalBookings, false),
            emiBookings.isEmpty
                ? const SizedBox()
                : buildSection(
                "EMI Bookings", emiBookings, true),
          ],
        ),
      ),
    );
  }
}
