import 'package:flutter/material.dart';
import '../Model/Car.dart';
import '../Model/Car_Mode.dart';
import 'Car_Detail_Screen.dart';// Ensure correct import

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = '';
  List<Car> filteredCars = [];

  @override
  void initState() {
    super.initState();
    filteredCars = sedanCars + suvCars + sportsCars + luxuryCars + offroadCars; // Combine all cars
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredCars = (sedanCars + suvCars + sportsCars + luxuryCars + offroadCars)
          .where((car) => car.name.toLowerCase().contains(searchQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search Cars")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              onChanged: updateSearch,
              decoration: InputDecoration(
                labelText: "Search for cars...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCars.length,
              itemBuilder: (context, index) {
                final car = filteredCars[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Image.asset(car.image, width: 80, height: 50, fit: BoxFit.cover),
                    title: Text(car.name, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("₹${car.totalPrice.toString()}"),
                    trailing: Text("${car.horsepower} HP"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarDetailScreen(car: car),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
