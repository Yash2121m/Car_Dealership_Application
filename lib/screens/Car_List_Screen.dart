import 'package:flutter/material.dart';
import '../Model/Car_Mode.dart';
import 'car_detail_screen.dart'; // Import the detail screen

class CarListScreen extends StatelessWidget {
  final List<Car> cars;

  const CarListScreen({Key? key, required this.cars}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Choose a car'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: darkTheme
                  ? [Colors.grey.shade800, Colors.black]
                  : [Colors.purpleAccent.shade100, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Map background (placeholder for now)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage("images/background.png")),
            ),
            margin: EdgeInsets.fromLTRB(0, 0, 0, 350),// Replace with Google Maps widget later
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 350,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: darkTheme ? Colors.grey.shade900 : Colors.grey.shade200,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: cars.length,
                itemBuilder: (context, index) {
                  final car = cars[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarDetailScreen(car: car),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.only(right: 16),
                      child: Container(
                        decoration: BoxDecoration(gradient: LinearGradient(
                          colors: [Colors.purpleAccent.shade100, Colors.blueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                          borderRadius: BorderRadius.all(Radius.circular(20))
                        ),
                        width: 200,
                        padding: const EdgeInsets.all(6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            SizedBox(height: 5,),
                            Text(
                              car.transmission,
                              style: const TextStyle(fontSize: 10),
                            ),
                            SizedBox(height: 10,),
                            Image.asset(
                              car.image,
                              height: 150,
                              fit: BoxFit.fitWidth,
                            ),
                            const SizedBox(height: 8),
                            Text('₹ ${car.totalPrice}'),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CarDetailScreen(car: car),
                                  ),
                                );
                              },
                              child: const Text('To See'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
