import 'package:intl/intl.dart';

String formatIndianPrice(num price) {
  if (price >= 10000000) {

    final value = price / 10000000;
    return "${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)} Cr";
  } else if (price >= 100000) {

    final value = price / 100000;
    return "${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)} L";
  } else if (price >= 1000) {

    return "${(price / 1000).toStringAsFixed(1)} K";
  } else {
    return price.toString();
  }
}


String formatDatePretty(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return '-';

  try {
    final date = DateTime.parse(isoDate);
    return DateFormat('d MMMM, yyyy').format(date);
  } catch (e) {
    return '-';
  }
}
