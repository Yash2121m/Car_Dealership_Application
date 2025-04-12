import 'package:flutter/material.dart';
import '../Model/Wishlist_Manager.dart'; // Add appropriate path

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late WishlistManager wishlistManager;

  @override
  void initState() {
    super.initState();
    wishlistManager = WishlistManager();
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = wishlistManager.wishlist;
    final bool darkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wishlist',
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
      ),
      body: wishlist.isEmpty ? const Center(
        child: Text(
          'Your wishlist is empty!',
          style: TextStyle(fontSize: 18),
        ),
      )
      : Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: wishlist.length,
          itemBuilder: (context, index) {
            final car = wishlist[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: darkTheme ? Colors.grey.shade800 : Colors.white,
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    car.image,
                    width: 100,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  car.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkTheme ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '₹ ${car.totalPrice}',
                    style: TextStyle(
                      fontSize: 16,
                      color: darkTheme ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.redAccent,
                  onPressed: () {
                    setState(() {
                      wishlistManager.toggleWishlistItem(car);
                    });
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
