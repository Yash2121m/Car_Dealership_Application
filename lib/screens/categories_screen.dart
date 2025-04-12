import 'package:flutter/material.dart';

import '../Model/Car.dart';
import 'Car_List_Screen.dart'; // Import car data models

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const first = Color(0xffffcf03);
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    // List of categories with titles, image paths, and corresponding car lists
    final List<Map<String, dynamic>> categories = [
      {'title': 'Sedan', 'image': 'images/sedan_logo.png', 'cars': sedanCars},
      {'title': 'SUV', 'image': 'images/suv_logo.png', 'cars': suvCars},
      {'title': 'Sports', 'image': 'images/sportscar_logo.png', 'cars': sportsCars},
      {'title': 'Luxurious', 'image': 'images/luxoury_logo.jpg', 'cars': luxuryCars},
      {'title': 'Offroad', 'image': 'images/off_road_logo.png', 'cars': offroadCars},
    ];

    return Scaffold(
      backgroundColor: darkTheme ? Colors.black87 : Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Categories",
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: darkTheme
                  ? [Colors.grey.shade800, Colors.black]
                  : [Colors.blue.shade300, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              // Navigate to CarListScreen and pass the selected car list
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarListScreen(cars: category['cars']),
                ),
              );
            },
            child: Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image Section
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.asset(
                      category['image'] as String, // Explicit type cast to String
                      fit: BoxFit.cover,
                      height: 200,
                    ),
                  ),
                  // Title Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purpleAccent.shade100, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                    ),
                    child: Text(
                      category['title'] as String, // Explicit type cast to String
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: darkTheme ? Colors.black : Colors.grey.shade200,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
