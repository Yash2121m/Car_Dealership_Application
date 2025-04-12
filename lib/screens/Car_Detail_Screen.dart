import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import the Fluttertoast package
import '../Model/Car_Mode.dart';
import '../Model/Wishlist_Manager.dart';
import 'Booking_Page.dart'; // Full Payment Booking Page
import 'EMI_Booking_Page.dart';
import 'Test_Drive_Page.dart'; // EMI Option Booking Page

class CarDetailScreen extends StatelessWidget {
  final Car car;

  const CarDetailScreen({Key? key, required this.car}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery
        .of(context)
        .platformBrightness == Brightness.dark;
    final wishlistManager = WishlistManager();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              wishlistManager.isInWishlist(car) ? Icons.favorite : Icons
                  .favorite_border,
              color: Colors.red,
            ),
            onPressed: () {
              wishlistManager.toggleWishlistItem(car);

              // Show toast message
              Fluttertoast.showToast(
                msg: wishlistManager.isInWishlist(car)
                    ? "Added to wishlist"
                    : "Removed from wishlist",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black,
                textColor: Colors.white,
              );

              // Force rebuild to update the icon
              (context as Element).markNeedsBuild();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Car Image Section
          Container(
            height: 250,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(car.image),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          // Car Information Section
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: darkTheme ? Colors.grey.shade900 : Colors.grey.shade300,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Car name and price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${car.transmission}',
                              style: TextStyle(
                                fontSize: 18,
                                color: darkTheme ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '₹ ${car.totalPrice}',
                          style: TextStyle(fontSize: 20, color: darkTheme
                              ? Colors.white
                              : Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Car specifications
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSpecificationItem(
                          icon: Icons.speed,
                          label: ' Speed: ${car.topSpeed} km/hr',
                          iconSize: 30,
                          color: Colors.purpleAccent,
                          labelStyle: TextStyle(fontSize: 12, color: Colors
                              .purpleAccent),
                        ),
                        _buildSpecificationItem(
                          icon: Icons.local_gas_station,
                          label: ' Milage: ${car.mileage} km/L',
                          color: darkTheme ? Colors.white : Colors.black,
                          iconSize: 30,
                          labelStyle: TextStyle(fontSize: 12),
                        ),
                        _buildSpecificationItem(
                          icon: Icons.electric_bolt,
                          label: 'HP: ${car.horsepower} Hp',
                          color: darkTheme ? Colors.white : Colors.black,
                          iconSize: 30,
                          labelStyle: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Car description
                    Text(
                      car.description,
                      style: TextStyle(fontSize: 15,
                          color: darkTheme ? Colors.white : Colors.black),
                    ),

                    // Spacer to push buttons to the bottom
                    const Spacer(),

                    // Test Drive Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TestDrivePage(car: car),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Text('Request Test Drive'),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Booking Buttons at Bottom
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingPage(car: car),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            child: const Text('Full Payment Booking'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EmiBookingPage(car: car),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            child: const Text('EMI Option'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSpecificationItem({
    required IconData icon,
    required String label,
    double iconSize = 24.0,
    Color color = Colors.black,
    TextStyle labelStyle = const TextStyle(fontSize: 14.0, color: Colors.black),
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: iconSize,
          color: color,
        ),
        Text(
          label,
          style: labelStyle,
        ),
      ],
    );
  }
}