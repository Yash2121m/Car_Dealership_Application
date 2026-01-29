import 'dart:ui';

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

class _AdminHomePageState extends State<AdminHomePage>
    with SingleTickerProviderStateMixin {
  int pendingCount = 0;
  int approvedCount = 0;
  int rejectedCount = 0;

  int get totalOrders =>
      pendingCount + approvedCount + rejectedCount;

  double get approvalRate =>
      totalOrders == 0 ? 0 : (approvedCount / totalOrders) * 100;

  double get rejectionRate =>
      totalOrders == 0 ? 0 : (rejectedCount / totalOrders) * 100;


  String userName = "Loading...";
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    fetchOrderStats();
    fetchUserName();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  void fetchUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final ref = FirebaseDatabase.instance.ref('users/$uid/name');
      final snapshot = await ref.get();
      setState(() {
        userName = snapshot.exists ? snapshot.value.toString() : "Admin";
      });
    }
  }

  void fetchOrderStats() {
    final ref = FirebaseDatabase.instance.ref("bookings");

    ref.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      int pending = 0, approved = 0, rejected = 0;

      if (data != null) {
        data.forEach((_, bookings) {
          if (bookings is Map) {
            bookings.forEach((_, booking) {
              final status = booking["status"];
              if (status == "pending") pending++;
              if (status == "approved") approved++;
              if (status == "rejected") rejected++;
            });
          }
        });
      }

      setState(() {
        pendingCount = pending;
        approvedCount = approved;
        rejectedCount = rejected;
        _animationController
          ..reset()
          ..forward();
      });
    });
  }

  // ---------- GLASS DASHBOARD CARD ----------
  Widget _buildDashboardCard(
      String title, int count, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: count.toDouble()),
        duration: const Duration(milliseconds: 900),
        builder: (_, value, __) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.7),
                      color.withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      child: Icon(icon, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------- GLASS DRAWER TILE ----------
  Widget _drawerTile(IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style:
        const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }

  // ---------- SUMMARY PAGE ----------
  Widget _buildAdminSummaryPage() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGreetingHeader(),

          // 🔔 REAL-TIME ALERT
          _buildPendingAlert(),

          _buildKpiRow(),

          const SizedBox(height: 20),

          _buildDashboardCard(
              "Pending Orders", pendingCount, Colors.orange, Icons.pending),
          _buildDashboardCard(
              "Approved Orders", approvedCount, Colors.green, Icons.check),
          _buildDashboardCard(
              "Rejected Orders", rejectedCount, Colors.red, Icons.close),

          _quickActions(),

          const SizedBox(height: 150,)
        ],
      ),
    );
  }


  Widget _buildGreetingHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Welcome back 👋",
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                userName,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorSys.purple1.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.analytics, color: Colors.deepPurple),
          )
        ],
      ),
    );
  }

  Widget _buildPendingAlert() {
    if (pendingCount == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminOrderReceivedScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.withOpacity(0.85),
              Colors.deepOrange.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.notifications_active,
                color: Colors.white, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                "$pendingCount pending order${pendingCount > 1 ? 's' : ''} waiting for approval",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }


  Widget _buildKpiRow() {
    return Row(
      children: [
        _kpiChip(
            "Total Orders",
            totalOrders.toString(),
            Icons.shopping_bag,
            Colors.blue),
        const SizedBox(width: 10),
        _kpiChip(
            "Approval",
            "${approvalRate.toStringAsFixed(0)}%",
            Icons.check_circle,
            Colors.green),
        const SizedBox(width: 10),
        _kpiChip(
            "Rejected",
            "${rejectionRate.toStringAsFixed(0)}%",
            Icons.cancel,
            Colors.red),
      ],
    );
  }

  Widget _kpiChip(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(value,
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _quickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        const Text("Quick Actions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            _actionCard(Icons.assignment, "All Orders",
                Colors.deepPurple, AdminOrdersScreen()),
            const SizedBox(width: 12),
            _actionCard(Icons.analytics, "Analytics",
                Colors.teal, AdminAnalyticsScreen()),
          ],
        ),
      ],
    );
  }

  Widget _actionCard(
      IconData icon,
      String title,
      Color color,
      Widget page,
      ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.75),
                color.withOpacity(0.95)
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 10),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
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
            gradient:
            LinearGradient(colors: [ColorSys.purple1, ColorSys.purple2]),
            borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text("Admin Dashboard",
                style:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
        ),
      ),

      // ---------- GLASS DRAWER ----------
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ClipRRect(
          borderRadius:
          const BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorSys.purple1.withOpacity(0.55),
                    ColorSys.purple2.withOpacity(0.25),
                  ],
                ),
              ),
              child: Column(
                children: [
                  UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(color: Colors.transparent),
                    accountName: Text(userName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    accountEmail: Text(
                      FirebaseAuth.instance.currentUser?.email ?? "",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    currentAccountPicture: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person,
                          size: 40, color: Colors.black),
                    ),
                  ),

                  _drawerTile(Icons.local_shipping_outlined, "Orders",
                      const AdminOrderReceivedScreen()),
                  _drawerTile(Icons.directions_car, "Test Drives",
                      const AdminTestDriveApprovalScreen()),
                  _drawerTile(
                      Icons.assignment, "All Orders", AdminOrdersScreen()),
                  _drawerTile(Icons.analytics, "Analytics",
                      AdminAnalyticsScreen()),

                  const Spacer(),

                  ListTile(
                    leading:
                    const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text("Logout",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ),

      body: _buildAdminSummaryPage(),
    );
  }
}
