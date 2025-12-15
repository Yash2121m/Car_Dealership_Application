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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70, right: 10),
        child: Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.purpleAccent.withOpacity(0.6),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                /// ✅ GLASS BLUR BACKGROUND
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.35),
                          ColorSys.purple2.withOpacity(0.35),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),

                /// ✅ MIRROR SHINE ON TOP
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 18,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.7),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ),

                /// ✅ BUTTON TAP AREA + LOTTIE
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatScreen()),
                      );
                    },
                    child: Center(
                      child: Lottie.asset(
                        "images/Bot.json",
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,



      // Creative Bottom Nav
      bottomNavigationBar: Container(
        // margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(2),
        height: 86,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              /// ✅ BLUR GLASS BACKGROUND
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
              ),

              /// ✅ MIRROR GLOSS SHINE (TOP REFLECTION)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 25,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.6),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
              ),

              /// ✅ BOTTOM NAV BAR
              BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                onTap: _navigationBar,
                selectedItemColor: Colors.purpleAccent,
                unselectedItemColor: Colors.white70,
                
                showSelectedLabels: true,
                showUnselectedLabels: false,
                selectedFontSize: 10,
                unselectedFontSize: 0,

                items: List.generate(4, (index) {
                  final icons = [
                    Icons.home,
                    Icons.local_shipping_outlined,
                    Icons.category_sharp,
                    Icons.person_2_rounded
                  ];

                  final labels = ["Home", "Orders", "Category", "Profile"];

                  final isSelected = _selectedIndex == index;

                  return BottomNavigationBarItem(
                    label: isSelected ? labels[index] : "",
                    icon: AnimatedScale(
                      scale: isSelected ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.45),
                              Colors.purpleAccent.withOpacity(0.3),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                              : null,
                          color: isSelected
                              ? null
                              : Colors.purpleAccent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Icon(
                          icons[index],
                          size: isSelected ? 26 : 22,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}