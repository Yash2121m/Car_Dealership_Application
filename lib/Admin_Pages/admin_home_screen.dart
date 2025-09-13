import 'package:cardealer/Assistance/ColorHelper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../screens/login_screen.dart';
import 'AdminAllOrders.dart';
import 'AdminAnalyticsScreen.dart';
import 'TestDriveApproval.dart';
import 'admin_order_received_screen.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> with SingleTickerProviderStateMixin {
  int pendingCount = 0;
  int approvedCount = 0;
  int rejectedCount = 0;

  String userName = "Loading...";

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    fetchOrderStats();
    fetchUserName();

    // Animation controller for counter animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }


  void fetchUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final ref = FirebaseDatabase.instance.ref().child('users/$uid/name');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        setState(() {
          userName = snapshot.value.toString();
        });
      } else {
        setState(() {
          userName = "No Name Found";
        });
      }
    }
  }

  void fetchOrderStats() {
    final DatabaseReference bookingsRef = FirebaseDatabase.instance.ref().child("bookings");

    bookingsRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      int pending = 0, approved = 0, rejected = 0;

      if (data != null) {
        data.forEach((userId, userBookings) {
          if (userBookings is Map) {
            userBookings.forEach((bookingId, bookingData) {
              String status = bookingData["status"] ?? "";
              if (status == "pending") pending++;
              else if (status == "approved") approved++;
              else if (status == "rejected") rejected++;
            });
          }
        });
      }

      setState(() {
        pendingCount = pending;
        approvedCount = approved;
        rejectedCount = rejected;
        _animationController.reset();
        _animationController.forward();
      });
    });
  }

  Widget _buildDashboardCard(String label, int count, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: count.toDouble()),
        duration: const Duration(seconds: 1),
        builder: (context, double value, child) {
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 6,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.7), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: Icon(icon, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
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

  Widget _drawerTile(IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: ColorSys.purple1),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
    );
  }

  Widget _buildAdminSummaryPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDashboardCard("Pending Orders", pendingCount, Colors.orange, Icons.pending_actions),
          _buildDashboardCard("Approved Orders", approvedCount, Colors.green, Icons.check_circle),
          _buildDashboardCard("Rejected Orders", rejectedCount, Colors.red, Icons.cancel),
        ],
      ),
    );
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
            title: const Text("Admin Dashboard",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [ColorSys.purple1, ColorSys.purple2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: Text(userName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(
                FirebaseAuth.instance.currentUser?.email ?? "",
                style: const TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.purple),
              ),
            ),
            _drawerTile(
                Icons.local_shipping_outlined, 'Orders', const AdminOrderReceivedScreen()),
            _drawerTile(Icons.directions_car_filled, 'Test Drives',
                const AdminTestDriveApprovalScreen()),
            _drawerTile(Icons.car_repair_sharp, 'All Orders',
                AdminOrdersScreen()),
            _drawerTile(Icons.analytics, 'Analysis',
                AdminAnalyticsScreen()),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
            ),
            SizedBox(height: 100,),
          ],
        ),
      ),
      body: _buildAdminSummaryPage(),
    );
  }
}
