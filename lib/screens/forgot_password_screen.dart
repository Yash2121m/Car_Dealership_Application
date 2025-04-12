import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cardealer/global/global.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotpasswordScreenState();
}

class _ForgotpasswordScreenState extends State<ForgotPasswordScreen> {

  final emailTextEditingController = TextEditingController();

  final form = GlobalKey<FormState>();

  void submit() {
    firebaseAuth.sendPasswordResetEmail(email: emailTextEditingController.text.trim()).then((value) {
      Fluttertoast.showToast(msg: "we have sent you an E-mail to recover password, Please check E-mail");
    }).onError((error, stackTrace){
      Fluttertoast.showToast(msg: "Error Occurred: \n ${error.toString()}");
    });
  }

  Key? get key => null;

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

                Text("Forgot Password",
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
                                child: Text("Send E-mail",
                                  style: TextStyle(
                                      fontSize: 20
                                  ),
                                ),
                              ),

                              SizedBox(height: 30,),
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