import 'package:cardealer/screens/login_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:cardealer/global/global.dart';
import 'package:cardealer/screens/main_page.dart';

class SignupScreen extends StatefulWidget{
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>{
  final nameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final confirmpasswordTextEditingController = TextEditingController();

  bool passwordVisible = false;

  final form = GlobalKey<FormState>();

  Key? get key => null;

  void submit() async{
    //Validate all the form fields
    if(form.currentState!.validate()) {
      await firebaseAuth.createUserWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim()
      ).then((auth) async {
        currentUser = auth.user;

        if(currentUser != null){
          Map userMap = {
            "id" : currentUser!.uid,
            "name" : nameTextEditingController.text.trim(),
            "email" : emailTextEditingController.text.trim(),
            "phone" : phoneTextEditingController.text.trim(),
            "address" : addressTextEditingController.text.trim(),
          };
          
          DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
          userRef.child(currentUser!.uid).set(userMap);

        }
        await Fluttertoast.showToast(msg: "Succressfully Registered");
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
    // TODO: implement build

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

                Text("Register",
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
                                  LengthLimitingTextInputFormatter(50),
                                ],
                                decoration:  InputDecoration(
                                  hintText: "Name",
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
                                  prefixIcon: Icon(Icons.person, color: darkTheme ? Colors.purpleAccent.shade100 : Colors.grey,),
                                ),
                                autovalidateMode:  AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if(text == null || text.isEmpty){
                                    return "Name can't be Empty";
                                  }
                                  if(text.length < 2) {
                                    return "Please enter a valid Name";
                                  }
                                  if(text.length > 49){
                                    return "Name can't be more than 50";
                                  }
                                },
                                onChanged: (text) => setState(() {
                                  nameTextEditingController.text = text;
                                }
                                ),
                              ),
                              SizedBox(height: 10,),

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
                              SizedBox(height: 10,),
                              
                              IntlPhoneField(
                                showCountryFlag: true,
                                dropdownIcon: Icon(Icons.arrow_drop_down,
                                  color: darkTheme ? Colors.purpleAccent.shade100 : Colors.grey,
                                ),
                               decoration: InputDecoration(
                                 hintText: "Phone No.",
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
                               ),
                                onChanged: (text) => setState(() {
                                  phoneTextEditingController.text = text.completeNumber;
                                }),
                              ),
                              SizedBox(height: 10,),

                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(100),
                                ],
                                decoration:  InputDecoration(
                                  hintText: "Address",
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
                                  prefixIcon: Icon(Icons.home, color: darkTheme ? Colors.purpleAccent.shade100 : Colors.grey,),
                                ),
                                autovalidateMode:  AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if(text == null || text.isEmpty){
                                    return "Address can't be Empty";
                                  }
                                  if(text.length < 2) {
                                    return "Please enter a valid Address";
                                  }
                                  if(text.length > 99){
                                    return "Address can't be more than 100";
                                  }
                                },
                                onChanged: (text) => setState(() {
                                  addressTextEditingController.text = text;
                                }
                                ),
                              ),
                              SizedBox(height: 10,),

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
                              SizedBox(height: 10,),

                              TextFormField(
                                obscureText: passwordVisible,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50),
                                ],
                                decoration:  InputDecoration(
                                  hintText: "Confirm Password",
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
                                  if(text != passwordTextEditingController.text){
                                    return "Password do not Match";
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
                                  confirmpasswordTextEditingController.text = text;
                                }
                                ),
                              ),
                              SizedBox(height: 10,),

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
                                child: Text("Register",
                                  style: TextStyle(
                                      fontSize: 20
                                  ),
                                ),
                              ),

                              SizedBox(height: 20,),

                              GestureDetector(
                                onTap: (){
                                },
                                child: Text("Forgot Password",
                                  style: TextStyle(
                                    color: darkTheme ? Colors.purpleAccent.shade100 : Colors.blue,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20,),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Have an Account",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(width: 5,),
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
                                    },
                                    child:  Text(
                                      "Sign In",
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