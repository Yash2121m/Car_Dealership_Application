import 'package:flutter/material.dart';

import '../Assistance/ColorHelper.dart';

class AccessoriesScreen extends StatefulWidget {
  const AccessoriesScreen({Key? key}) : super(key: key);

  @override
  _AccessoriesScreenState createState() => _AccessoriesScreenState();
}

class _AccessoriesScreenState extends State<AccessoriesScreen> {

  final List<Map<String, dynamic>> accessories = [
    {
      "name": "Rear Parking Sensors",
      "price": 3000,
      "image": "images/accessories/rear_parking_sensors.jpg"
    },
    {
      "name": "Spare Tire + Toolkit",
      "price": 4000,
      "image": "images/accessories/spare_tire.jpg"
    },
    {
      "name": "Floor Mats",
      "price": 1200,
      "image": "images/accessories/floor_mats.jpg"
    },
    {
      "name": "Sun Visors",
      "price": 800,
      "image": "images/accessories/sun_visors.jpg"
    },
    {
      "name": "Glove Box",
      "price": 1500,
      "image": "images/accessories/glove_box.jpg"
    },
    {
      "name": "Dashcam",
      "price": 5000,
      "image": "images/accessories/dash_cam.jpg"
    },
    {
      "name": "Seat Covers",
      "price": 3500,
      "image": "images/accessories/seat_covers.jpg"
    },
    {
      "name": "Steering Wheel Cover",
      "price": 600,
      "image": "images/accessories/steering_wheel_cover.jpg"
    },
    {
      "name": "Car Perfumes",
      "price": 400,
      "image": "images/accessories/car_perfumes.jpg"
    },
    {
      "name": "Seat Cushions & Neck Pillows",
      "price": 1000,
      "image": "images/accessories/neck_pillows.jpg"
    },
    {
      "name": "Armrest Organizers",
      "price": 900,
      "image": "images/accessories/armrest_organizers.jpg"
    },
    {
      "name": "GPS Navigation Unit",
      "price": 7000,
      "image": "images/accessories/gps_navigation_unit.jpg"
    },
    {
      "name": "Car Cleaning Kit",
      "price": 1200,
      "image": "images/accessories/car_cleaning_kits.jpg"
    },
  ];


  final Set<int> selectedIndexes = {};


  int get totalPrice {
    return selectedIndexes.fold(0, (sum, index) => sum + accessories[index]["price"] as int);
  }

  @override
  Widget build(BuildContext context) {
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
            title: const Text("Select Accessories",
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
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: accessories.length,
              itemBuilder: (context, index) {
                final accessory = accessories[index];
                final isSelected = selectedIndexes.contains(index);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedIndexes.remove(index);
                      } else {
                        selectedIndexes.add(index);
                      }
                    });
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.asset(
                              accessory["image"],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                accessory["name"],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "₹${accessory["price"]}",
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: ColorSys.purple2,
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                            ),
                            child: const Center(
                              child: Text(
                                "Selected",
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: const Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total: ₹$totalPrice",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    final selectedAccessories = selectedIndexes.map((i) => accessories[i]).toList();
                    Navigator.pop(context, {
                      "accessories": selectedAccessories,
                      "total": totalPrice,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorSys.purple2,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Confirm"),
                ),

              ],
            ),
          )
        ],
      ),
    );
  }
}
