import 'Car_Mode.dart';

class WishlistManager {
  static final WishlistManager _instance = WishlistManager._internal();
  final List<Car> _wishlist = [];

  factory WishlistManager() => _instance;

  WishlistManager._internal();

  List<Car> get wishlist => _wishlist;

  void toggleWishlistItem(Car car) {
    if (_wishlist.contains(car)) {
      _wishlist.remove(car);
    } else {
      _wishlist.add(car);
    }
  }

  bool isInWishlist(Car car) {
    return _wishlist.contains(car);
  }
}
