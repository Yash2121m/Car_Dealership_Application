
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cardealer/Assistance/assistant_method.dart';
import 'package:cardealer/global/global.dart';
import 'package:cardealer/screens/login_screen.dart';
import 'package:cardealer/screens/main_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {



  Key? get key => null;

  startTimer(){
    Timer(Duration(seconds: 3), () async {
      if(await firebaseAuth.currentUser != null){
        firebaseAuth.currentUser != null ? AssistantMethods.readCurrentOnLineUserInfo() : null;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen(key)));
      }
      else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => LoginScreen()));
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    startTimer();
  }

  @override
  Widget build(BuildContext context){
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("images/logo2.gif",
              width: 300,
            ),
            Text("Auto Star",
                style: TextStyle(
                fontSize: 60,
              fontWeight: FontWeight.bold,
                  color: darkTheme ? Colors.purpleAccent.shade100 : Colors.blue,
            ),
            ),
          ],
        ),
      )
    );
  }
}