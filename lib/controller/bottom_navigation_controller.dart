import 'package:cardealer/screens/main_page.dart';
import 'package:cardealer/screens/wishlist.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:get/get.dart';

class BottomNavigationController extends GetxController {
  RxInt index = 0.obs;

  var pages = [
    MainScreen(key),
    WishlistScreen(),
    MainScreen(key),
    WishlistScreen(),
  ];

  static Key? get key => null;
}
