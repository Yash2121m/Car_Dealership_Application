import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cardealer/screens/login_screen.dart';
import 'package:cardealer/screens/main_page.dart';
import 'package:cardealer/screens/signup_screen.dart';
import 'package:cardealer/splash_screen/splash_screen.dart';
import 'package:cardealer/themeProvider/themeProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
