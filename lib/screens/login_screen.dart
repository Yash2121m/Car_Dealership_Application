import 'package:cardealer/screens/signup_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:cardealer/screens/forgot_password_screen.dart';

import '../global/global.dart';
import 'main_page.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {

  final emailTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();

  bool passwordVisible = false;

  final form = GlobalKey<FormState>();

  Key? get key => null;

  void submit() async{
    //Validate all the form fields
    if(form.currentState!.validate()) {
      await firebaseAuth.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim()
      ).then((auth) async {
        currentUser = auth.user;

        await Fluttertoast.showToast(msg: "Succressfully Logged In");
        Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen(key)));
      }
      ).catchError((errorMessage){
        Fluttertoast.showToast(msg: "Error Occured: \n $errorMessage");
      });
    }
    else{
      Fluttertoast.showToast(msg: "Not all fields are Valid");
    }
  }

  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Image.asset(darkTheme ? 'images/Dark.jpg' : 'images/light.jpg', height: 200, width: 200,),

                SizedBox(height: 20 ,),

                Text("Log-In",
                  style: TextStyle(
                    color: darkTheme ? Colors.purpleAccent.shade100 : Colors.blue ,
                    fontSize:  25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(15, 20, 15, 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Form(
                          key: form,
                          child: Column(
                            mainAxisAlignment:  MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(100),
                                ],
                                decoration:  InputDecoration(
                                  hintText: "E-mail",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  filled: true,
                                  fillColor: darkTheme ? Colors.grey.shade900 : Colors.grey.shade200,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      )
                                  ),
                                  prefixIcon: Icon(Icons.email, color: darkTheme ? Colors.purpleAccent.shade100 : Colors.grey,),
                                ),
                                autovalidateMode:  AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if(text == null || text.isEmpty){
                                    return "E-mail can't be Empty";
                                  }
                                  if(EmailValidator.validate(text) == true) {
                                    return null;
                                  }
                                  if(text.length < 2) {
                                    return "Please enter a valid E-mail";
                                  }
                                  if(text.length > 99){
                                    return "E-mail can't be more than 100";
                                  }
                                },
                                onChanged: (text) => setState(() {
                                  emailTextEditingController.text = text;
                                }
                                ),
                              ),
                              SizedBox(height: 30,),

                              TextFormField(
                                obscureText: passwordVisible,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50),
                                ],
                                decoration:  InputDecoration(
                                  hintText: "Password",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  filled: true,
                                  fillColor: darkTheme ? Colors.grey.shade900 : Colors.grey.shade200,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      )
                                  ),
                                  prefixIcon: Icon(Icons.password, color: darkTheme ? Colors.purpleAccent.shade100 : Colors.grey,),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      passwordVisible ? Icons.visibility : Icons.visibility_off,
                                      color: darkTheme ? Colors.purpleAccent.shade100 : Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        passwordVisible =! passwordVisible;
                                      });
                                    },
                                  ),
                                ),
                                autovalidateMode:  AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if(text == null || text.isEmpty){
                                    return "Password can't be Empty";
                                  }
                                  if(text.length < 2) {
                                    return "Please enter a valid Password";
                                  }
                                  if(text.length > 49){
                                    return "Password can't be more than 50";
                                  }
                                  return null;
                                },
                                onChanged: (text) => setState(() {
                                  passwordTextEditingController.text = text;
                                }
                                ),
                              ),
                              SizedBox(height: 30,),

                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: darkTheme ? Colors.black : Colors.white,
                                  foregroundColor: darkTheme ? Colors.purpleAccent.shade100 : Colors.blue,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  minimumSize: Size(300, 50),
                                ),
                                onPressed: (){
                                  submit();
                                },
                                child: Text("Log-in",
                                  style: TextStyle(
                                      fontSize: 20
                                  ),
                                ),
                              ),

                              SizedBox(height: 30,),

                              GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (c) => ForgotPasswordScreen()));
                                },
                                child: Text("Forgot Password",
                                  style: TextStyle(
                                    color: darkTheme ? Colors.purpleAccent.shade100 : Colors.blue,
                                  ),
                                ),
                              ),
                              SizedBox(height: 30,),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Doesn't have an Account",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(width: 5,),
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (c) => SignupScreen()));
                                    },
                                    child:  Text(
                                      "Register",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: darkTheme ? Colors.purpleAccent.shade100 : Colors.blue,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          )
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
}