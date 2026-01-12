import 'dart:ui';
import 'package:cardealer/Assistance/ColorHelper.dart';
import 'package:cardealer/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cardealer/Model/user_model.dart';
import 'package:lottie/lottie.dart';

import '../global/global.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? userModel;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // 🚫 Block guest users
    if (isGuest || FirebaseAuth.instance.currentUser == null) {
      return;
    }

    fetchUserProfile();
  }

  void fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DatabaseReference userRef =
    FirebaseDatabase.instance.ref().child("users").child(user.uid);

    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        setState(() {
          userModel = UserModel.fromSnapshot(snap.snapshot);
        });
      }
    });
  }

  /// ---------------- EDIT PROFILE ----------------
  void showEditProfileDialog() {
    if (isGuest) return;

    nameController.text = userModel?.name ?? "";
    addressController.text = userModel?.address ?? "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: Colors.white.withOpacity(0.9),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Edit Profile",
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Name",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: "Address",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;

                      if (nameController.text.trim().isNotEmpty &&
                          addressController.text.trim().isNotEmpty) {
                        await FirebaseDatabase.instance
                            .ref()
                            .child("users")
                            .child(user.uid)
                            .update({
                          "name": nameController.text.trim(),
                          "address": addressController.text.trim(),
                        });

                        Navigator.pop(context);
                        fetchUserProfile();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorSys.purple1,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ---------------- DETAIL TILE ----------------
  Widget buildDetailTile(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor:
                  ColorSys.purple1.withOpacity(0.15),
                  child: Icon(icon,
                      color: ColorSys.purple1, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(value,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
            title: const Text("Profile",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,

            actions: [
              IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black87),
                  onPressed: showEditProfileDialog),
            ],
          ),
        ),
      ),

      /// ---------------- BODY ----------------
      body: isGuest || user == null
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
              "Please login to access your profile",
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
              child: const Text("Go to Login",
                  style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      )
          : userModel == null
          ? Center(
        child: Lottie.asset(
          "images/Travel_app.json",
          width: 250,
          height: 250,
        ),
      )
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SizedBox(height: 30,),
            Center(
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ColorSys.purple1.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 3,
                    )
                  ],
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              ColorSys.purple1.withOpacity(0.6),
                              ColorSys.purple2.withOpacity(0.6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ColorSys.purple1.withOpacity(0.5),
                              blurRadius: 25,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white.withOpacity(0.9),
                        child: const Icon(Icons.person,
                            size: 60, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            buildDetailTile(
                "Name", userModel?.name ?? "-", Icons.person),
            buildDetailTile(
                "Email", userModel?.email ?? "-", Icons.email),
            buildDetailTile(
                "Phone", userModel?.phone ?? "-", Icons.phone),
            buildDetailTile(
                "Address", userModel?.address ?? "-", Icons.location_on),
            const SizedBox(height: 30),

            /// SIGN OUT
            ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                isGuest = false;

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.logout, color: Colors.black),
              label: const Text(
                "Sign Out",
                style: TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorSys.purple1,
                padding: const EdgeInsets.symmetric(
                    horizontal: 60, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
            const SizedBox(height: 150),
          ],
        ),
      ),
    );
  }
}
