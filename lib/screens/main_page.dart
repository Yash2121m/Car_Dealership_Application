import 'package:cardealer/controller/bottom_navigation_controller.dart';
import 'package:cardealer/screens/Home_screen.dart';
import 'package:cardealer/screens/categories_screen.dart';
import 'package:cardealer/screens/profile_screen.dart';
import 'package:cardealer/screens/wishlist.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

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
    WishlistScreen(),
    CategoryScreen(),
    ProfileScreen(),
  ];

  Key? get key => null;

  @override
  Widget build(BuildContext context){
    const first = Color(0xff2E073F);
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    BottomNavigationController controller = Get.put(BottomNavigationController());
    return Scaffold(
      bottomNavigationBar:BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: darkTheme ? Colors.purpleAccent.shade100 : Colors.blue,
          onTap: _navigationBar,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                label: "Wishlists"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.category_sharp),
                label: "Category"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_2_rounded),
                label: "Profile"
            ),
          ]
      ),
      body: _navigationList[_selectedIndex],
    );
  }
}