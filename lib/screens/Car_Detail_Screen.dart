import 'dart:ui';

import 'package:cardealer/Assistance/ColorHelper.dart';
import 'package:cardealer/Model/AllCars.dart';
import 'package:cardealer/screens/Car_Compare.dart';
import 'package:cardealer/screens/EMI_Booking_Page.dart';
import 'package:cardealer/screens/Test_Drive_Page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import '../Model/Car_Mode.dart';
import '../Model/Price_Formatter.dart';
import '../Model/Wishlist_Manager.dart';
import 'Booking_Page.dart';

class CarDetailScreen extends StatefulWidget {
  final Car car;

  const CarDetailScreen({Key? key, required this.car}) : super(key: key);

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen>
    with SingleTickerProviderStateMixin{
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  bool isLoading = true;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _isFavorite = WishlistManager().isInWishlist(widget.car);
    _controller = AnimationController(vsync: this);


    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final wishlistManager = WishlistManager();
    final List<String> imageList = widget.car.images;

    return Scaffold(
      backgroundColor: ColorSys.carback,
      body: isLoading
          ? Center(
        child: Lottie.asset(
          "images/Pouring_Oil.json",
          controller: _controller,
          width: 220,
          height: 220,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..repeat(period: composition.duration * 0.5);
          },
        ),
      )
          : SafeArea(
        child: Column(
          children: [

            Stack(
              children: [
                SizedBox(
                  height: 260,
                  child: PageView.builder(
                    itemCount: imageList.length,
                    onPageChanged: (index) {
                      setState(() => _currentImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return Image.asset(
                        imageList[index],
                        fit: BoxFit.contain,
                        width: double.infinity,
                      );
                    },
                  ),
                ),


                Positioned(
                  top: 8,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _circleBtn(
                        Icons.arrow_back,
                            () => Navigator.pop(context),
                      ),
                      _circleBtn(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                            () {
                          setState(() {
                            _isFavorite = !_isFavorite;
                            wishlistManager.toggleWishlistItem(widget.car);
                          });
                          Fluttertoast.showToast(
                            msg: _isFavorite
                                ? "Added to Wishlist"
                                : "Removed from Wishlist",
                            toastLength: Toast.LENGTH_SHORT,
                          );
                        },
                        color: _isFavorite ? Colors.red : Colors.black,
                      ),
                    ],
                  ),
                ),


                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(imageList.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentImageIndex == index ? 12 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentImageIndex == index
                              ? Colors.blueAccent
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }
                    ),
                  ),
                ),
              ],
            ),


            Expanded(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: ColorSys.purple1,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.car.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              widget.car.bodyType,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 6),


                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            // "₹${widget.car.totalPrice}",
                            '₹ ${formatIndianPrice(widget.car.totalPrice)}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: const [
                              Icon(Icons.star,
                                  color: Colors.amber, size: 20),
                              SizedBox(width: 4),
                              Text("4.6",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),


                      Text(
                        widget.car.description,
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.4),
                      ),
                      const SizedBox(height: 20),


                      const Text("Highlights",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _featureTile(Icons.event_seat, "Capacity",
                              "${widget.car.seats} Seats"),
                          _featureTile(Icons.speed, "Top Speed",
                              "${widget.car.topSpeed} Km/H"),
                          _featureTile(Icons.bolt, "Power",
                              "${widget.car.horsepower} HP"),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _featureTile(Icons.settings, "Transmission",
                              widget.car.transmission),
                          _featureTile(Icons.local_gas_station, "Fuel Tank",
                              "${widget.car.fuelTankCapacity} L"),
                          _featureTile(Icons.eco, "Mileage",
                              "${widget.car.mileage} Km/L"),
                        ],
                      ),

                      const SizedBox(height: 24),



                      const Text(
                        "Specifications",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(

                              color: Colors.white.withOpacity(0.50),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.55),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.18),
                                  blurRadius: 14,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _specRow("Body Type", widget.car.bodyType),
                                _specRow("Number of Doors", "${widget.car.numberOfDoors}"),
                                _specRow("Length", "${widget.car.totalLength} mm"),
                                _specRow("Width", "${widget.car.overallWidth} mm"),
                                _specRow("Height", "${widget.car.overallHeight} mm"),
                                _specRow("Wheelbase", "${widget.car.wheelbase} mm"),
                                _specRow("Ground Clearance", "${widget.car.groundClearance} mm"),
                                _specRow("Boot Capacity", "${widget.car.bootCapacity} L"),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 26),


                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (c) =>
                                      EmiBookingPage(car: widget.car),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              child: const Text("EMI Calculator",
                                  style: TextStyle(fontSize: 15)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (c) =>
                                      BookingPage(car: widget.car),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Colors.deepPurple),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              child: const Text("Buy Now",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),


                      _linkRow("🚗 Wanna Test the Car ?", "Book a Test Drive",
                              () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) =>
                                      TestDrivePage(car: widget.car)))),
                      const SizedBox(height: 12),
                      _linkRow(
                          "⚖️ Wanna Compare the Car ?", "Compare Now",
                              () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => CompareCarsScreen(
                                      currentCar: widget.car,
                                      allCars: allCars)))),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap, {Color color = Colors.black}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.7),
              border: Border.all(
                color: Colors.white.withOpacity(0.9),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
      ),
    );
  }


  Widget _featureTile(IconData icon, String title, String value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: 105,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(

            color: Colors.grey.shade200.withOpacity(0.65),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, size: 26, color: Colors.deepPurple),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _specRow(String key, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: const TextStyle(fontSize: 15),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkRow(String text, String action, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            )),
        InkWell(
          onTap: onTap,
          child: Text(" $action",
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple)),
        ),
      ],
    );
  }
}

