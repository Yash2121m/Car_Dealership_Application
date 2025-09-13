import 'package:cardealer/screens/login_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:cardealer/global/global.dart';
import 'package:cardealer/screens/main_page.dart';
import 'package:animate_do/animate_do.dart';

import '../Assistance/ColorHelper.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final confirmpasswordTextEditingController = TextEditingController();

  bool passwordVisible = false;
  final form = GlobalKey<FormState>();
  Key? get key => null;

  void submit() async {
    if (form.currentState!.validate()) {
      await firebaseAuth
          .createUserWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim())
          .then((auth) async {
        currentUser = auth.user;

        if (currentUser != null) {
          // Send email verification
          await currentUser!.sendEmailVerification();

          // Save user data
          Map userMap = {
            "id": currentUser!.uid,
            "name": nameTextEditingController.text.trim(),
            "email": emailTextEditingController.text.trim(),
            "phone": phoneTextEditingController.text.trim(),
            "address": addressTextEditingController.text.trim(),
          };

          DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child("users");
          await userRef.child(currentUser!.uid).set(userMap);

          Fluttertoast.showToast(
              msg:
              "Verification email sent! Please verify before logging in.");

          await firebaseAuth.signOut();

          // Redirect to login screen
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (c) => const LoginScreen()));
        }
      }).catchError((errorMessage) {
        Fluttertoast.showToast(msg: "Error Occurred: \n $errorMessage");
      });
    } else {
      Fluttertoast.showToast(msg: "Not all fields are Valid");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = false;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Image.asset(
                  darkTheme ? 'images/Dark.jpg' : 'images/light_1.png',
                  height: 200,
                  width: 200,
                ),
                SizedBox(height: 20),
                FadeInUp(
                  duration: Duration(milliseconds: 800),
                  child: Text(
                    "Register",
                    style: TextStyle(
                      color: darkTheme
                          ? Colors.purpleAccent.shade100
                          : ColorSys.purple2,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 20, 15, 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FadeInUp(
                        duration: Duration(milliseconds: 1000),
                        child: Form(
                          key: form,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              buildTextField(
                                controller: nameTextEditingController,
                                hint: "Name",
                                icon: Icons.person,
                                validator: (text) =>
                                    _validateText(text, 50, "Name"),
                              ),
                              SizedBox(height: 10),
                              buildTextField(
                                controller: emailTextEditingController,
                                hint: "E-mail",
                                icon: Icons.email,
                                validator: _validateEmail,
                              ),
                              SizedBox(height: 10),
                              IntlPhoneField(
                                showCountryFlag: true,
                                dropdownIcon: Icon(
                                  Icons.arrow_drop_down,
                                  color: darkTheme
                                      ? Colors.purpleAccent.shade100
                                      : Colors.grey,
                                ),
                                decoration:
                                _inputDecoration("Phone No.", darkTheme),
                                onChanged: (text) => setState(() {
                                  phoneTextEditingController.text =
                                      text.completeNumber;
                                }),
                              ),
                              SizedBox(height: 10),
                              buildTextField(
                                controller: addressTextEditingController,
                                hint: "Address",
                                icon: Icons.home,
                                validator: (text) =>
                                    _validateText(text, 100, "Address"),
                              ),
                              SizedBox(height: 10),
                              buildTextField(
                                controller: passwordTextEditingController,
                                hint: "Password",
                                icon: Icons.password,
                                obscure: passwordVisible,
                                isPassword: true,
                              ),
                              SizedBox(height: 10),
                              buildTextField(
                                controller: confirmpasswordTextEditingController,
                                hint: "Confirm Password",
                                icon: Icons.password,
                                obscure: passwordVisible,
                                isPassword: true,
                                validator: (text) {
                                  if (text !=
                                      passwordTextEditingController.text) {
                                    return "Password do not Match";
                                  }
                                  return _validateText(text, 50, "Password");
                                },
                              ),
                              SizedBox(height: 10),
                              FadeInUp(
                                delay: Duration(milliseconds: 400),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    darkTheme ? Colors.black : Colors.white,
                                    foregroundColor: darkTheme
                                        ? Colors.purpleAccent.shade100
                                        : ColorSys.purple2,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    minimumSize: Size(300, 50),
                                  ),
                                  onPressed: submit,
                                  child: Text("Register",
                                      style: TextStyle(fontSize: 20)),
                                ),
                              ),
                              SizedBox(height: 20),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  "Forgot Password",
                                  style: TextStyle(
                                    color: darkTheme
                                        ? Colors.purpleAccent.shade100
                                        : ColorSys.purple2,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Have an Account",
                                    style:
                                    TextStyle(color: Colors.grey, fontSize: 15),
                                  ),
                                  SizedBox(width: 5),
                                  GestureDetector(
                                    onTap: () => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (c) => LoginScreen())),
                                    child: Text(
                                      "Sign In",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: darkTheme
                                            ? Colors.purpleAccent.shade100
                                            : ColorSys.purple2,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  String? _validateText(String? text, int maxLength, String fieldName) {
    if (text == null || text.isEmpty) return "$fieldName can't be Empty";
    if (text.length < 2) return "Please enter a valid $fieldName";
    if (text.length > maxLength) return "$fieldName can't be more than $maxLength";
    return null;
  }

  String? _validateEmail(String? text) {
    if (text == null || text.isEmpty) return "E-mail can't be Empty";
    if (EmailValidator.validate(text)) return null;
    if (text.length < 2) return "Please enter a valid E-mail";
    if (text.length > 99) return "E-mail can't be more than 100";
    return "Invalid email format";
  }

  InputDecoration _inputDecoration(String hint, bool darkTheme) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey),
      filled: true,
      fillColor: darkTheme ? Colors.grey.shade900 : Colors.grey.shade200,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(40),
        borderSide: BorderSide(width: 0, style: BorderStyle.none),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    bool darkTheme = false;
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? obscure : false,
      inputFormatters: [LengthLimitingTextInputFormatter(100)],
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: darkTheme ? Colors.grey.shade900 : Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(width: 0, style: BorderStyle.none),
        ),
        prefixIcon:
        Icon(icon, color: darkTheme ? Colors.purpleAccent.shade100 : Colors.grey),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            obscure ? Icons.visibility : Icons.visibility_off,
            color: darkTheme ? Colors.purpleAccent.shade100 : Colors.grey,
          ),
          onPressed: () => setState(() => passwordVisible = !passwordVisible),
        )
            : null,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator ?? (text) => _validateText(text, 100, hint),
      onChanged: (text) => setState(() {}),
    );
  }
}
