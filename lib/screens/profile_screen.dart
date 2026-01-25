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

  int carsOwnedCount = 0;
  int testDrivesCount = 0;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (isGuest || FirebaseAuth.instance.currentUser == null) return;

    fetchUserProfile();
    fetchStats();
  }

  /// ---------------- USER PROFILE ----------------
  Future<void> fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snap = await FirebaseDatabase.instance
        .ref("users/${user.uid}")
        .get();

    if (snap.exists) {
      setState(() {
        userModel = UserModel.fromSnapshot(snap);
      });
    }
  }

  /// ---------------- STATS ----------------
  Future<void> fetchStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ownedSnap = await FirebaseDatabase.instance
        .ref("bookings/${user.uid}")
        .get();

    final testSnap = await FirebaseDatabase.instance
        .ref("testDrive/${user.uid}")
        .get();

    setState(() {
      carsOwnedCount =
      ownedSnap.exists ? (ownedSnap.value as Map).length : 0;

      testDrivesCount =
      testSnap.exists ? (testSnap.value as Map).length : 0;
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
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(25)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  color: Colors.white.withOpacity(0.95),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom:
                      MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Edit Profile",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),

                        TextField(
                          controller: nameController,
                          decoration:
                          const InputDecoration(labelText: "Name"),
                        ),

                        const SizedBox(height: 15),

                        TextField(
                          controller: addressController,
                          decoration:
                          const InputDecoration(labelText: "Address"),
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final user =
                                  FirebaseAuth.instance.currentUser;
                              if (user == null) return;

                              await FirebaseDatabase.instance
                                  .ref("users/${user.uid}")
                                  .update({
                                "name": nameController.text.trim(),
                                "address":
                                addressController.text.trim(),
                              });

                              Navigator.pop(context);
                              fetchUserProfile();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorSys.purple1,
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              "Save",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar:  PreferredSize(
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
        child: Column(
          children: [
            buildProfileHeader(),
            buildContactCard(),
            const SizedBox(height: 30),
            _logoutButton(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  /// ---------------- UI WIDGETS ----------------

  Widget buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
        LinearGradient(colors: [ColorSys.purple1, ColorSys.purple2]),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white24,
                child: Text(userModel!.name![0].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userModel!.name!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text(
                        isGuest ? "Guest User" : "Verified User",
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ]),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem("Cars Owned", "$carsOwnedCount"),
              _StatItem("Test Drives", "$testDrivesCount"),
            ],
          )
        ],
      ),
    );
  }

  Widget buildContactCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Contact Information",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _contactRow(Icons.email, userModel!.email!),
          _contactRow(Icons.phone, userModel!.phone!),
          _contactRow(Icons.location_on, userModel!.address!),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: ColorSys.purple1),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _logoutButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.logout),
      label: const Text("Sign Out"),
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorSys.purple1,
      ),
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        const SizedBox(height: 4),
        Text(title,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
