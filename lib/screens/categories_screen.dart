import 'dart:ui';
import 'package:cardealer/Assistance/ColorHelper.dart';
import 'package:flutter/material.dart';
import '../Model/Car.dart';
import 'Car_List_Screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

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
                          final scale = Tween(begin: 0.95, end: 1.0).animate(
                            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                          );
                          return FadeTransition(
                            opacity: fade,
                            child: ScaleTransition(scale: scale, child: child),
                          );
                        },
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 25,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        children: [
                          /// 🚗 Car image with subtle purple tint
                          Hero(
                            tag: category['title'],
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                Colors.purpleAccent.withOpacity(0.12),
                                BlendMode.softLight,
                              ),
                              child: Image.asset(
                                category['image'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 220,
                              ),
                            ),
                          ),

                          /// 🌒 Dark–to–transparent gradient overlay (for contrast)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.75),
                                    Colors.black.withOpacity(0.25),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),

                          /// ✨ Glass info panel with mirror shine
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 18,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.18),
                                        Colors.white.withOpacity(0.05),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.45),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      /// mirror shine strip
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

                                      /// content
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    category['title'],
                                                    style: const TextStyle(
                                                      fontSize: 22,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(12),
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.white.withOpacity(0.5),
                                                        Colors.purpleAccent.withOpacity(0.6),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    "${(category['cars'] as List).length} cars",
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              category['subtitle'],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
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

          // spacing so it doesn't touch glossy bottom nav
          const SizedBox(height: 50),
        ],
      )

    );
  }
}
