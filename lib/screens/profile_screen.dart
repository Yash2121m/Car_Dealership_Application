import 'package:cardealer/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cardealer/global/global.dart';
import 'package:cardealer/Model/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  void fetchUserProfile() async {
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(currentUser!.uid);

    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        setState(() {
          userModel = UserModel.fromSnapshot(snap.snapshot);
        });
      }
    });
  }

  Widget buildDetailCard(String label, String value, bool darkTheme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: darkTheme ? Colors.purpleAccent.shade100 : Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  color: darkTheme ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: darkTheme
                  ? [Colors.grey.shade800, Colors.black]
                  : [Colors.blue.shade300, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body: userModel == null ? const Center(child: CircularProgressIndicator())
       : SingleChildScrollView(
        child: Column(
          children: [
            // Avatar Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: darkTheme ? Colors.purpleAccent.shade100 : Colors.blue,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: darkTheme ? Colors.black : Colors.white,
                ),
              ),
            ),
            // Profile Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildDetailCard("Name", userModel!.name ?? "N/A", darkTheme),
                  buildDetailCard("Email", userModel!.email ?? "N/A", darkTheme),
                  buildDetailCard("Phone", userModel!.phone ?? "N/A", darkTheme),
                  buildDetailCard("Address", userModel!.address ?? "N/A", darkTheme),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Sign Out Button
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  // Navigate to login screen or landing page after signing out
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()), // Replace `MyHomePage` with your login screen widget
                  );
                } catch (e) {
                  // Handle errors
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Error"),
                      content: Text(e.toString()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: darkTheme ? Colors.purpleAccent.shade100 : Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text(
                "Sign Out",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
