import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lottie/lottie.dart';

import '../global/global.dart';
import '../Assistance/ColorHelper.dart';
import '../screens/login_screen.dart';
import '../main.dart'; // flutterLocalNotificationsPlugin

class MaintenanceReminderScreen extends StatefulWidget {
  const MaintenanceReminderScreen({Key? key}) : super(key: key);

  @override
  State<MaintenanceReminderScreen> createState() =>
      _MaintenanceReminderScreenState();
}

class _MaintenanceReminderScreenState extends State<MaintenanceReminderScreen>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> carReminders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 🚫 Block guest users
    if (isGuest || FirebaseAuth.instance.currentUser == null) {
      isLoading = false;
      return;
    }

    fetchBookings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        !isGuest &&
        FirebaseAuth.instance.currentUser != null) {
      fetchBookings();
    }
  }

  Future<void> fetchBookings() async {
    setState(() => isLoading = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => isLoading = false);
      return;
    }

    final ref = FirebaseDatabase.instance.ref().child("bookings/$uid");
    final snapshot = await ref.get();

    List<Map<String, dynamic>> reminders = [];

    if (snapshot.exists) {
      final Map data = snapshot.value as Map;

      for (var entry in data.entries) {
        final booking = entry.value;

        if (booking['paymentDone'] == true &&
            booking['timestamp'] != null) {
          final date = DateTime.tryParse(booking['timestamp']);
          if (date == null) continue;

          final firstService =
          date.add(const Duration(days: 30)).difference(DateTime.now());
          final insurance =
          date.add(const Duration(days: 365)).difference(DateTime.now());
          final pollution =
          date.add(const Duration(days: 90)).difference(DateTime.now());
          final tyreRotation =
          date.add(const Duration(days: 180)).difference(DateTime.now());
          final brakeCheck =
          date.add(const Duration(days: 200)).difference(DateTime.now());
          final batteryCheck =
          date.add(const Duration(days: 900)).difference(DateTime.now());

          if (firstService.inDays <= 0) {
            await showLocalNotification(
              "First Service Due",
              "${booking['carName']} needs its first service!",
            );
          }

          reminders.add({
            'carName': booking['carName'] ?? 'N/A',
            'bookingDate': date,
            'tasks': [
              {
                "title": "First Service",
                "time": firstService,
                "icon": Icons.build_circle
              },
              {
                "title": "Insurance Renewal",
                "time": insurance,
                "icon": Icons.policy
              },
              {
                "title": "Pollution Check",
                "time": pollution,
                "icon": Icons.cloud
              },
              {
                "title": "Tyre Rotation",
                "time": tyreRotation,
                "icon": Icons.circle
              },
              {
                "title": "Brake Service",
                "time": brakeCheck,
                "icon": Icons.car_crash
              },
              {
                "title": "Battery Check",
                "time": batteryCheck,
                "icon": Icons.battery_full
              },
            ]
          });
        }
      }
    }

    setState(() {
      carReminders = reminders;
      isLoading = false;
    });
  }

  Future<void> showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'maintenance_channel',
      'Maintenance Notifications',
      channelDescription: 'Car maintenance reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  String formatDuration(Duration duration) {
    if (duration.inDays <= 0) return "⚠️ Due now!";
    if (duration.inDays <= 30) {
      return "⏳ ${duration.inDays} days (Due soon)";
    }
    return "${duration.inDays} days remaining";
  }

  Color getStatusColor(Duration duration) {
    if (duration.inDays <= 0) return Colors.red.shade300;
    if (duration.inDays <= 30) return Colors.orange.shade300;
    return Colors.green.shade300;
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
            title: const Text(
              "Car Maintenance Tracker",
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
              "Please login to view maintenance reminders",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: ColorSys.purple1),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LoginScreen()),
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
          : isLoading
          ? Center(
        child: Lottie.asset(
          "images/Travel_app.json",
          width: 250,
          height: 250,
        ),
      )
          : carReminders.isEmpty
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
              "No Reminders found",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: carReminders.length,
        itemBuilder: (context, index) {
          final reminder = carReminders[index];
          return Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder['carName'],
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Booking Date: ${DateFormat.yMMMd().format(reminder['bookingDate'])}",
                    style: const TextStyle(
                        fontSize: 14, color: Colors.grey),
                  ),
                  const Divider(height: 20),
                  ...reminder['tasks'].map<Widget>((task) {
                    final time = task['time'] as Duration;
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 6),
                      decoration: BoxDecoration(
                        color: getStatusColor(time),
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Icon(task['icon']),
                        title: Text(task['title'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        subtitle:
                        Text(formatDuration(time)),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
