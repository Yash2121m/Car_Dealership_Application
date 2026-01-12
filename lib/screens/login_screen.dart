import 'package:animate_do/animate_do.dart';
import 'package:cardealer/Admin_Pages/BottomNavigationAdmin.dart';
import 'package:cardealer/Assistance/ColorHelper.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cardealer/screens/signup_screen.dart';
import 'package:cardealer/screens/forgot_password_screen.dart';

import '../global/global.dart';
import 'main_page.dart';
bool isGuest = false;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final form = GlobalKey<FormState>();

  bool passwordVisible = false;

  /// ---------------- USER LOGIN ----------------
  void submit() async {
    if (form.currentState!.validate()) {
      try {
        final auth = await firebaseAuth.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        );

        currentUser = auth.user;

        if (currentUser != null && currentUser!.emailVerified) {
          isGuest = false;

          Fluttertoast.showToast(msg: "Successfully Logged In");

          // ADMIN LOGIN
          if (currentUser!.email == "yashspatil2121m@gmail.com") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BottomNavAdmin(null),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(null),
              ),
            );
          }
        } else {
          Fluttertoast.showToast(
              msg: "Email not verified. Please check your inbox.");
          await firebaseAuth.signOut();
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Login failed: $e");
      }
    } else {
      Fluttertoast.showToast(msg: "Not all fields are valid");
    }
  }

  /// ---------------- GUEST LOGIN ----------------
  void guestLogin() {
    isGuest = true;
    currentUser = null;

    Fluttertoast.showToast(msg: "Logged in as Guest");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(null),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = false;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: darkTheme ? Colors.black : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: darkTheme ? Colors.black : Colors.white,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Form(
                  key: form,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          FadeInUp(
                            duration: const Duration(milliseconds: 1000),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: ColorSys.purple2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          FadeInUp(
                            duration: const Duration(milliseconds: 1200),
                            child: const Text(
                              "Login to your account",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),

                      /// ---------------- EMAIL & PASSWORD ----------------
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: [
                            FadeInUp(
                              duration: const Duration(milliseconds: 1200),
                              child: TextFormField(
                                controller: emailTextEditingController,
                                keyboardType: TextInputType.emailAddress,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(100)
                                ],
                                decoration: inputDecoration("Email"),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "Email can't be empty";
                                  }
                                  if (!EmailValidator.validate(text)) {
                                    return "Enter valid email";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            FadeInUp(
                              duration: const Duration(milliseconds: 1300),
                              child: TextFormField(
                                controller: passwordTextEditingController,
                                obscureText: !passwordVisible,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50)
                                ],
                                decoration: inputDecoration("Password").copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        passwordVisible = !passwordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "Password can't be empty";
                                  }
                                  if (text.length < 6) {
                                    return "Minimum 6 characters";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// ---------------- LOGIN BUTTON ----------------
                      FadeInUp(
                        duration: const Duration(milliseconds: 1400),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: MaterialButton(
                            height: 60,
                            minWidth: double.infinity,
                            color: ColorSys.purple2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            onPressed: submit,
                            child: const Text(
                              "Log-in",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                      ),

                      /// ---------------- GUEST BUTTON ----------------
                      FadeInUp(
                        duration: const Duration(milliseconds: 1500),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: OutlinedButton(
                            onPressed: guestLogin,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              side:
                              BorderSide(color: ColorSys.purple2, width: 2),
                            ),
                            child: Text(
                              "Continue as Guest",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ColorSys.purple2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      /// ---------------- FORGOT & SIGNUP ----------------
                      FadeInUp(
                        duration: const Duration(milliseconds: 1600),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ForgotPasswordScreen()),
                            );
                          },
                          child: Text("Forgot Password?",
                              style: TextStyle(color: ColorSys.purple2)),
                        ),
                      ),

                      FadeInUp(
                        duration: const Duration(milliseconds: 1700),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? "),
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => SignupScreen()),
                                );
                              },
                              child: Text(
                                "Sign up",
                                style: TextStyle(
                                  color: ColorSys.purple2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// ---------------- IMAGE ----------------
              FadeInUp(
                duration: const Duration(milliseconds: 1200),
                child: Container(
                  height: MediaQuery.of(context).size.height / 3,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/light.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
