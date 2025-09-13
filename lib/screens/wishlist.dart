import 'package:cardealer/Assistance/ColorHelper.dart';
import 'package:flutter/material.dart';
import '../Model/Wishlist_Manager.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with SingleTickerProviderStateMixin {
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
            title: const Text("Wishlists",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: wishlist.isEmpty
          ? const Center(
        child: Text(
          'Your wishlist is empty!',
          style: TextStyle(fontSize: 18),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: wishlist.length,
          itemBuilder: (context, index) {
            final car = wishlist[index];

            return Dismissible(
              key: Key(car.name),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                final removedCar = car;
                setState(() {
                  wishlistManager.toggleWishlistItem(car);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${removedCar.name} removed from wishlist"),
                    action: SnackBarAction(
                      label: "UNDO",
                      onPressed: () {
                        setState(() {
                          wishlistManager.toggleWishlistItem(removedCar);
                        });
                      },
                    ),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: darkTheme ? Colors.grey.shade800 : Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        car.images[0],
                        height: 60,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      car.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                        darkTheme ? Colors.white : Colors.grey.shade900,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '₹ ${car.totalPrice}',
                        style: TextStyle(
                          fontSize: 16,
                          color: darkTheme
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
