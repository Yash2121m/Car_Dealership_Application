import 'package:flutter/material.dart';
import 'Orders.dart';
import 'SearchScreen.dart';
import 'SliderHome.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            },
          ),
          IconButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderedCarScreen()),
            );
          },
              icon: Icon(Icons.local_shipping_outlined))
        ],
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SliderHome(),
            ),
            // Popular Brands Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Popular Brands",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBrandIcon('images/toyota.png'),
                  SizedBox(width: 10,),
                  _buildBrandIcon('images/honda.png'),
                  SizedBox(width: 10,),
                  _buildBrandIcon('images/bmw.png'),
                  SizedBox(width: 10,),
                  _buildBrandIcon('images/audi.png'),
                  SizedBox(width: 10,),
                  _buildBrandIcon('images/mercedes.png'),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Most Sold Vehicles Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Most Sold Vehicles",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildVehicleCard(
                  image: 'images/sedan1.png',
                  name: 'Toyota Camry',
                  price: '₹ 25,00,000',
                ),
                _buildVehicleCard(
                  image: 'images/suv41.png',
                  name: 'Honda CR-V',
                  price: '₹ 27,00,000',
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildVehicleCard(
                  image: 'images/sports2.png',
                  name: 'Porsche 911',
                  price: '₹ 60,00,000',
                ),
                _buildVehicleCard(
                  image: 'images/luxury2.png',
                  name: 'Mercedes-Benz S-class',
                  price: '₹ 90,00,000',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build brand icons
  Widget _buildBrandIcon(String imagePath) {
    return CircleAvatar(
      radius: 40,
      backgroundImage: AssetImage(imagePath),
    );
  }

  // Widget to build vehicle cards
  Widget _buildVehicleCard({required String image, required String name, required String price}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        width: 150,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.asset(
                image,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
