String formatIndianPrice(num price) {
  if (price >= 10000000) {
    // Crores
    final value = price / 10000000;
    return "${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)} Cr";
  } else if (price >= 100000) {
    // Lakhs
    final value = price / 100000;
    return "${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)} L";
  } else if (price >= 1000) {
    // Thousands
    return "${(price / 1000).toStringAsFixed(1)} K";
  } else {
    return price.toString();
  }
}
