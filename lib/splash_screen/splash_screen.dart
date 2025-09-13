import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cardealer/Admin_Pages/BottomNavigationAdmin.dart';
import 'package:cardealer/screens/Home_screen.dart';
import 'package:flutter/material.dart';
import 'package:cardealer/Assistance/assistant_method.dart';
import 'package:cardealer/global/global.dart';
import 'package:cardealer/screens/login_screen.dart';
import 'package:cardealer/screens/main_page.dart';
import 'package:cardealer/controller/Splash_ColorsSys.dart';
import 'package:cardealer/controller/Splash_String.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Admin_Pages/admin_home_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late PageController _pageController;
  int currentIndex = 0;

  Key? get key => null;

  @override
  void initState() {
    _pageController = PageController(
        initialPage: 0
    );
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorSys.splashBack,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ColorSys.splashBack,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20, top: 20),
            child: GestureDetector(
              onTap: () {
                User? user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  final isAdmin = user.email == 'yashspatil2121m@gmail.com';

                  if (isAdmin) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => BottomNavAdmin(key)),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen(key)),
                    );
                  }
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }
              },


              child: Text(
                'Skip',
                style: TextStyle(
                  color: ColorSys.gray,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          PageView(
            onPageChanged: (int page) {
              setState(() {
                currentIndex = page;
              });
            },
            controller: _pageController,
            children: <Widget>[
              makePage(
                  image: 'images/splash1.png',
                  title: Strings.stepOneTitle,
                  content: Strings.stepOneContent
              ),
              makePage(
                  reverse: true,
                  image: 'images/splash2.png',
                  title: Strings.stepTwoTitle,
                  content: Strings.stepTwoContent
              ),
              makePage(
                  image: 'images/splash3.png',
                  title: Strings.stepThreeTitle,
                  content: Strings.stepThreeContent
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(bottom: 60),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildIndicator(),
            ),
          )
        ],
      ),
    );
  }

  Widget makePage({image, title, content, reverse = false}) {
    return Container(
      padding: EdgeInsets.only(left: 30, right: 30, bottom: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          !reverse ?
          Column(
            children: <Widget>[
              FadeInUp(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Image.asset(image),
                ),
              ),
              SizedBox(height: 30,),
            ],
          ) : SizedBox(),
          FadeInUp(
              duration: Duration(milliseconds: 900),
              child: Text(title, style: TextStyle(
                  color: ColorSys.primary,
                  fontSize: 25,
                  fontWeight: FontWeight.bold
              ),)),
          SizedBox(height: 20,),
          FadeInUp(
              duration: Duration(milliseconds: 1200),
              child: Text(content, textAlign: TextAlign.center, style: TextStyle(
                  color: ColorSys.gray,
                  fontSize: 20,
                  fontWeight: FontWeight.w400
              ),)),
          reverse ?
          Column(
            children: <Widget>[
              SizedBox(height: 30,),
              FadeInUp(

                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Image.asset(image),
                ),
              ),
            ],
          ) : SizedBox(),
        ],
      ),
    );
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: 6,
      width: isActive ? 30 : 6,
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(5)
      ),
    );
  }

  List<Widget> _buildIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i<3; i++) {
      if (currentIndex == i) {
        indicators.add(_indicator(true));
      } else {
        indicators.add(_indicator(false));
      }
    }

    return indicators;
  }
}