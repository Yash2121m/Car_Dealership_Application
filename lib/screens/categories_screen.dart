import 'dart:ui';
import 'package:cardealer/Assistance/ColorHelper.dart';
import 'package:flutter/material.dart';
import '../Model/Car.dart';
import 'Car_List_Screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool darkTheme = false;

    final List<Map<String, dynamic>> categories = [
      {'title': 'Sedan', 'subtitle': 'Comfort & Style', 'image': 'images/sedan_logo.png', 'cars': sedanCars},
      {'title': 'SUV', 'subtitle': 'Power & Space', 'image': 'images/suv_logo_1.png', 'cars': suvCars},
      {'title': 'Coupe', 'subtitle': 'Sporty & Sleek', 'image': 'images/sportscar_logo.png', 'cars': Coupe},
      {'title': 'Hatchback', 'subtitle': 'Compact & Smart', 'image': 'images/hatchback_logo1.png', 'cars': Hatchback},
      {'title': 'Convertible', 'subtitle': 'Luxury & Fun', 'image': 'images/convertible_logo.png', 'cars': Convertible},
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ColorSys.purple1, ColorSys.purple2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: AppBar(
            title: const Text("Car Categories",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 600),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            CarListScreen(cars: category['cars']),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          final fade = Tween(begin: 0.0, end: 1.0).animate(animation);
                          final scale = Tween(begin: 0.9, end: 1.0)
                              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack));
                          return FadeTransition(
                            opacity: fade,
                            child: ScaleTransition(scale: scale, child: child),
                          );
                        },
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        children: [
                          Hero(
                            tag: category['title'],
                            child: Image.asset(
                              category['image'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 220,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  color: Colors.black.withOpacity(0.3),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category['title'],
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        category['subtitle'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 50,)
        ],
      ),
    );
  }
}
