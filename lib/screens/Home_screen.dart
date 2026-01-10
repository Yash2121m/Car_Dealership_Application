import 'package:cardealer/Assistance/ColorHelper.dart';
import 'package:cardealer/screens/Car_Detail_Screen.dart';
import 'package:cardealer/screens/ChatBot_Screen.dart';
import 'package:cardealer/screens/wishlist.dart';
import 'package:flutter/material.dart';
import 'BrandCarScreen.dart';
import 'Maintenance_Reminder_Screen.dart';
import 'MessageToAdmin.dart';
import 'Orders.dart';
import 'SearchScreen.dart';
import 'SliderHome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Test_Drive_Details.dart';
import 'login_screen.dart';
import '../Model/Car_Mode.dart';
import '../Model/AllCars.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "Loading...";


  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  void fetchUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final ref = FirebaseDatabase.instance.ref().child('users/$uid/name');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        setState(() {
          userName = snapshot.value.toString();
        });
      } else {
        setState(() {
          userName = "No Name Found";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = false;

    return Scaffold(
      // Custom Gradient AppBar
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
            title: const Text("Home",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),

      // Creative Drawer
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [ColorSys.purple1, ColorSys.purple2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: Text(userName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(
                FirebaseAuth.instance.currentUser?.email ?? "",
                style: const TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.purple),
              ),
            ),
            _drawerTile(Icons.favorite, 'Wishlist', const WishlistScreen()),
            _drawerTile(
                Icons.local_shipping_outlined, 'Orders', const OrderedCarScreen()),
            _drawerTile(Icons.directions_car_filled, 'Test Drives',
                const TestDriveHistoryPage()),
            _drawerTile(Icons.car_repair_sharp, 'Maintenance',MaintenanceReminderScreen()),
            _drawerTile(Icons.accessibility_rounded, 'ChatBot', ChatScreen()),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
            ),
            SizedBox(height: 120,),
          ],
        ),
      ),

      // Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi, $userName 👋",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            _buildSearchBar(context),

            GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MessagingPage()),
                );
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorSys.purple1.withOpacity(0.15),
                      ColorSys.purple2.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.support_agent, color: Colors.purple),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Need help choosing a car? Chat with our expert",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 14),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: SliderHome(),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _quickAction(context, Icons.car_rental, "Test Drive",
                    const TestDriveHistoryPage()),
                _quickAction(context, Icons.local_shipping, "Orders",
                    const OrderedCarScreen()),
                _quickAction(context, Icons.favorite, "Wishlist",
                    const WishlistScreen()),
              ],
            ),



            // Popular Brands
            _sectionTitle("Popular Brands", darkTheme),
            const SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildBrandIcon('images/ToyotaLogo.jpg', "Toyota", darkTheme),
                  _buildBrandIcon('images/McLarenLogo.png', "McLaren", darkTheme),
                  _buildBrandIcon('images/BMWLogo.jpg', "BMW", darkTheme),
                  _buildBrandIcon('images/NissanLogo.jpg', "Nissan", darkTheme),
                  _buildBrandIcon('images/MercedesLogo.jpg', "Mercedes", darkTheme),
                  _buildBrandIcon('images/VolkswagenLogo.jpg', "Volkswagen", darkTheme),
                  _buildBrandIcon('images/VolvoLogo.png', "Volvo", darkTheme),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Most Sold Cars
            _sectionTitle("Most Sold Vehicles", darkTheme),
            const SizedBox(height: 10),
            SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allCars.take(6).length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildVehicleCard(car: allCars[index]),
                  );
                },
              ),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: ColorSys.purple2),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
    );
  }

  // Glass-morphism Search Bar
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => SearchScreen()));
          },
          readOnly: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.black54),
            hintText: "Search cars...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black54),
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool darkTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: darkTheme? Colors.white : Colors.black87),
      ),
    );
  }

  // Brand Icon with animation
  Widget _buildBrandIcon(String imagePath, String brandName, bool darkTheme) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BrandCarsScreen(brand: brandName)),
        );
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(3),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ColorSys.purple1, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage(imagePath),
            ),
          ),
          const SizedBox(height: 6),
          Text(brandName,
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: darkTheme? Colors.white : Colors.black87)),
        ],
      ),
    );
  }

  // Creative Vehicle Card
  Widget _buildVehicleCard({required Car car}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CarDetailScreen(car: car)),
        );
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                car.images[0],
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(car.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                  const SizedBox(height: 4),
                  Text("₹${car.totalPrice}",
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _quickAction(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
    ) {
  return InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: () =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
    child: Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: ColorSys.purple1.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ColorSys.purple1.withOpacity(0.9),
                  ColorSys.purple2.withOpacity(0.9),
                ],
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
