import 'dart:ui';
import 'package:cardealer/controller/bottom_navigation_controller.dart';
import 'package:cardealer/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'AdminMessagingPage.dart';
import 'admin_home_screen.dart';
import 'admin_order_received_screen.dart';


class BottomNavAdmin extends StatefulWidget{
  const BottomNavAdmin(Key? key) : super(key: key);

  @override
  State<BottomNavAdmin> createState() => _BottomNavAdmin();
}

class _BottomNavAdmin extends State<BottomNavAdmin> {
  int _selectedIndex = 0;

  void _navigationBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _navigationList = [
    AdminHomePage(),
    AdminOrderReceivedScreen(),
    AdminMessagingPage(),
    ProfileScreen(),
  ];

  Key? get key => null;

  @override
  Widget build(BuildContext context){
    BottomNavigationController controller =
    Get.put(BottomNavigationController());

    return Scaffold(
      extendBody: true,
      body: _navigationList[_selectedIndex],
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
                    padding: EdgeInsets.all(
                      _selectedIndex == 0 ? 10 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedIndex == 0
                          ? Colors.purpleAccent.withOpacity(0.2)
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Transform.scale(
                      scale: _selectedIndex == 0 ? 1.55 : 1.0,
                      child: const Icon(Icons.home),
                    ),

                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.all(
                      _selectedIndex == 1 ? 10 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedIndex == 1
                          ? Colors.purpleAccent.withOpacity(0.2)
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Transform.scale(
                      scale: _selectedIndex == 1 ? 1.55 : 1.0,
                      child: const Icon(Icons.local_shipping_outlined),
                    ),
                  ),
                  label: "Orders",
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.all(
                      _selectedIndex == 2 ? 10 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedIndex == 2
                          ? Colors.purpleAccent.withOpacity(0.2)
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Transform.scale(
                      scale: _selectedIndex == 2 ? 1.55 : 1.0,
                      child: const Icon(Icons.message_outlined),
                    ),
                  ),
                  label: "Messages",
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.all(
                      _selectedIndex == 3 ? 10 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedIndex == 3
                          ? Colors.purpleAccent.withOpacity(0.2)
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Transform.scale(
                      scale: _selectedIndex == 3 ? 1.55 : 1.0,
                      child: const Icon(Icons.person_2_rounded),
                    ),
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