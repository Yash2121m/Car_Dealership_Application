import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lottie/lottie.dart'; // ✅ Added
import 'package:cardealer/global/global.dart';
import 'package:cardealer/Assistance/ColorHelper.dart';

import '../main.dart'; // For flutterLocalNotificationsPlugin

class MaintenanceReminderScreen extends StatefulWidget {
  const MaintenanceReminderScreen({Key? key}) : super(key: key);

  @override
  State<MaintenanceReminderScreen> createState() => _MaintenanceReminderScreenState();
}

class _MaintenanceReminderScreenState extends State<MaintenanceReminderScreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> carReminders = [];
  bool isLoading = true; // ✅ Added state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchBookings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchBookings();
    }
  }

  Future<void> fetchBookings() async {
    setState(() => isLoading = true); // ✅ Show loader
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final ref = FirebaseDatabase.instance.ref().child("bookings").child(uid);
    final snapshot = await ref.get();

    if (snapshot.exists) {
      Map data = snapshot.value as Map;
      List<Map<String, dynamic>> reminders = [];

      for (var entry in data.entries) {
        final booking = entry.value;
        if (booking['paymentDone'] == true && booking['timestamp'] != null) {
          final date = DateTime.tryParse(booking['timestamp']);
          if (date != null) {
            final firstService = date.add(const Duration(days: 30)).difference(DateTime.now());
            final insurance = date.add(const Duration(days: 365)).difference(DateTime.now());
            final pollution = date.add(const Duration(days: 90)).difference(DateTime.now());
            final tyreRotation = date.add(const Duration(days: 180)).difference(DateTime.now());
            final brakeCheck = date.add(const Duration(days: 200)).difference(DateTime.now());
            final batteryCheck = date.add(const Duration(days: 900)).difference(DateTime.now());

            if (firstService.inDays <= 0) {
              await showLocalNotification("First Service Due", "${booking['carName']} needs its first service!");
            }
            if (insurance.inDays <= 0) {
              await showLocalNotification("Insurance Renewal Due", "${booking['carName']} insurance needs renewal!");
            }
            if (pollution.inDays <= 0) {
              await showLocalNotification("Pollution Check Due", "${booking['carName']} needs a pollution check!");
            }
            if (tyreRotation.inDays <= 0) {
              await showLocalNotification("Tyre Service Due", "Rotate or check tyres of ${booking['carName']}!");
            }
            if (brakeCheck.inDays <= 0) {
              await showLocalNotification("Brake Check Due", "Inspect brakes of ${booking['carName']} for safety!");
            }
            if (batteryCheck.inDays <= 0) {
              await showLocalNotification("Battery Check Due", "Battery health check required for ${booking['carName']}!");
            }

            reminders.add({
              'carName': booking['carName'] ?? 'N/A',
              'bookingDate': date,
              'tasks': [
                {"title": "First Service", "time": firstService, "icon": Icons.build_circle},
                {"title": "Insurance Renewal", "time": insurance, "icon": Icons.policy},
                {"title": "Pollution Check", "time": pollution, "icon": Icons.cloud},
                {"title": "Tyre Rotation", "time": tyreRotation, "icon": Icons.circle},
                {"title": "Brake Service", "time": brakeCheck, "icon": Icons.car_crash},
                {"title": "Battery Check", "time": batteryCheck, "icon": Icons.battery_full},
              ]
            });
          }
        }
      }

      setState(() {
        carReminders = reminders;
        isLoading = false; // ✅ Hide loader
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'maintenance_channel',
      'Maintenance Notifications',
      channelDescription: 'Car maintenance reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformDetails,
    );
  }

  String formatDuration(Duration duration) {
    if (duration.inDays <= 0) return "⚠️ Due now!";
    if (duration.inDays <= 30) return "⏳ ${duration.inDays} days (Due soon)";
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
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: AppBar(
            title: const Text("Car Maintenance Tracker",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
          fit: BoxFit.contain,
        ),
      )
          : carReminders.isEmpty
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
              "No Reminders found",
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
        padding: const EdgeInsets.all(16),
        itemCount: carReminders.length,
        itemBuilder: (context, index) {
          final reminder = carReminders[index];
          return Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reminder['carName'],
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("Booking Date: ${DateFormat.yMMMd().format(reminder['bookingDate'])}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const Divider(height: 20, thickness: 1),
                  if (reminder['tasks'] != null) ...reminder['tasks'].map<Widget>((task) {
                    final time = task['time'] as Duration;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: getStatusColor(time),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Icon(task['icon'], color: Colors.black87),
                        title: Text(task['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(formatDuration(time)),
                      ),
                    );
                  }).toList()
                  else
                    const Text("No tasks available", style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
