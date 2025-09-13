import 'dart:ui';

import 'package:cardealer/Assistance/ColorHelper.dart';
import 'package:cardealer/controller/bottom_navigation_controller.dart';
import 'package:cardealer/screens/Home_screen.dart';
import 'package:cardealer/screens/MessageToAdmin.dart';
import 'package:cardealer/screens/categories_screen.dart';
import 'package:cardealer/screens/profile_screen.dart';
import 'package:cardealer/screens/wishlist.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lottie/lottie.dart';

import 'ChatBot_Screen.dart';
import 'Orders.dart';

class MainScreen extends StatefulWidget{
  const MainScreen(Key? key) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _navigationBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _navigationList = [
    HomeScreen(),
    OrderedCarScreen(),
    CategoryScreen(),
    ProfileScreen(),
  ];

  Key? get key => null;

  @override
  Widget build(BuildContext context){
    BottomNavigationController controller =
    Get.put(BottomNavigationController());

    return Scaffold(
      extendBody: true, // allows nav bar to float over body
      body: _navigationList[_selectedIndex],
      // Floating Action Button for Chat
      // Floating Action Button for Chat
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70, right: 10), // adjust spacing above nav bar
        child: FloatingActionButton(
          backgroundColor: ColorSys.purple2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Lottie.asset(
            "images/Bot.json", // ✅ Your loader
            width: 250,
            height: 250,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatScreen()),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,



      // Creative Bottom Nav
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomNavigationBar(
              backgroundColor: Colors.white.withOpacity(0.2),
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: _navigationBar,
              selectedItemColor: Colors.purpleAccent,
              unselectedItemColor: Colors.white70,
              showUnselectedLabels: false,
              items: [
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _selectedIndex == 0
                          ? Colors.purpleAccent.withOpacity(0.2)
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.home),
                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _selectedIndex == 1
                          ? Colors.purpleAccent.withOpacity(0.2)
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.local_shipping_outlined),
                  ),
                  label: "Orders",
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _selectedIndex == 2
                          ? Colors.purpleAccent.withOpacity(0.2)
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.category_sharp),
                  ),
                  label: "Category",
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _selectedIndex == 3
                          ? Colors.purpleAccent.withOpacity(0.2)
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.person_2_rounded),
                  ),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}