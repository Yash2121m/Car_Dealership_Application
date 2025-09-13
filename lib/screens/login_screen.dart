import 'package:animate_do/animate_do.dart';
import 'package:cardealer/Admin_Pages/BottomNavigationAdmin.dart';
import 'package:cardealer/Assistance/ColorHelper.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cardealer/screens/signup_screen.dart';
import 'package:cardealer/screens/forgot_password_screen.dart';
import '../Admin_Pages/admin_home_screen.dart';
import '../global/global.dart';
import 'main_page.dart';


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

  Key? get key => null;

  void submit() async {
    if (form.currentState!.validate()) {
      await firebaseAuth
          .signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim())
          .then((auth) async {
        currentUser = auth.user;

        if (currentUser != null && currentUser!.emailVerified) {
          await Fluttertoast.showToast(msg: "Successfully Logged In");

          // Check for admin email
          if (currentUser!.email == "yashspatil2121m@gmail.com") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>  BottomNavAdmin(key)),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen(key)),
            );
          }
        } else {
          await Fluttertoast.showToast(
              msg: "Email not verified. Please check your inbox.");
          await firebaseAuth.signOut();
        }
      }).catchError((errorMessage) {
        Fluttertoast.showToast(msg: "Error Occurred:\n $errorMessage");
      });
    } else {
      Fluttertoast.showToast(msg: "Not all fields are valid");
    }
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
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Form(
                  key: form,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          FadeInUp(
                            duration: Duration(milliseconds: 1000),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: darkTheme
                                      ? Colors.purpleAccent.shade100
                                      : ColorSys.purple2),
                            ),
                          ),
                          SizedBox(height: 20),
                          FadeInUp(
                            duration: Duration(milliseconds: 1200),
                            child: Text(
                              "Login to your account",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: darkTheme
                                      ? Colors.grey[400]
                                      : Colors.grey[700]),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: <Widget>[
                            FadeInUp(
                              duration: Duration(milliseconds: 1200),
                              child: TextFormField(
                                controller: emailTextEditingController,
                                keyboardType: TextInputType.emailAddress,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(100),
                                ],
                                decoration: InputDecoration(
                                  hintText: "Email",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 10),
                                  filled: true,
                                  fillColor: darkTheme
                                      ? Colors.grey.shade900
                                      : Colors.grey.shade100,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade400),
                                  ),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade400)),
                                ),
                                autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "Email can't be empty";
                                  }
                                  if (!EmailValidator.validate(text)) {
                                    return "Please enter a valid email";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: 20),
                            FadeInUp(
                              duration: Duration(milliseconds: 1300),
                              child: TextFormField(
                                controller: passwordTextEditingController,
                                obscureText: !passwordVisible,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50),
                                ],
                                decoration: InputDecoration(
                                  hintText: "Password",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 10),
                                  filled: true,
                                  fillColor: darkTheme
                                      ? Colors.grey.shade900
                                      : Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade400),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade400),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(
                                        color: darkTheme
                                            ? Colors.purpleAccent
                                            : ColorSys.purple2),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      passwordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: darkTheme
                                          ? Colors.purpleAccent.shade100
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        passwordVisible = !passwordVisible;
                                      });
                                    },
                                  ),
                                ),
                                autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "Password can't be empty";
                                  }
                                  if (text.length < 2) {
                                    return "Enter a valid password";
                                  }
                                  if (text.length > 49) {
                                    return "Password too long";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      FadeInUp(
                        duration: Duration(milliseconds: 1400),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: MaterialButton(
                            minWidth: double.infinity,
                            height: 60,
                            onPressed: submit,
                            color: darkTheme
                                ? Colors.purpleAccent.shade100
                                : ColorSys.purple2,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                            child: Text(
                              "Log-in",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: darkTheme ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      FadeInUp(
                        duration: Duration(milliseconds: 1500),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) => ForgotPasswordScreen()));
                          },
                          child: Text("Forgot Password?",
                              style: TextStyle(
                                  color: darkTheme
                                      ? Colors.purpleAccent.shade100
                                      : ColorSys.purple2)),
                        ),
                      ),
                      FadeInUp(
                          duration: Duration(milliseconds: 1500),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Don't have an account?",
                                  style: TextStyle(
                                      color: darkTheme
                                          ? Colors.grey
                                          : Colors.black)),
                              InkWell(
                                child: Text(
                                  " Sign up",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: darkTheme
                                          ? Colors.purpleAccent.shade100
                                          : ColorSys.purple2),
                                ),
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (c) => SignupScreen()));
                                },
                              ),
                            ],
                          ))
                    ],
                  ),
                ),
              ),
              FadeInUp(
                duration: Duration(milliseconds: 1200),
                child: Container(
                  height: MediaQuery.of(context).size.height / 3,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(darkTheme
                          ? 'images/Dark.jpg'
                          : 'images/light.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
