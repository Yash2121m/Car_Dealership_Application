import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'main_page.dart';

class OTPScreen extends StatefulWidget {
  final String email;

  const OTPScreen({super.key, required this.email});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  bool isVerified = false;

  Key? get key => null;

  @override
  void initState() {
    super.initState();
    _checkVerification();
  }

  Future<void> _checkVerification() async {
    await Future.delayed(Duration(seconds: 3)); // simulate delay

    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    if (user != null && user.emailVerified) {
      setState(() => isVerified = true);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen(key)));
    } else {
      Fluttertoast.showToast(msg: "Email not verified. Try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Center(
        child: isVerified
            ? const CircularProgressIndicator()
            : const Text("Waiting for email verification..."),
      ),
    );
  }
}
