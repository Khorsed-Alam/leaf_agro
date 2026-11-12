import 'package:intl/intl.dart';

class DateFormatter {
  static String formatTimestamp(DateTime dateTime, {String locale = 'en'}) {
    final formatter = DateFormat('MMM d, yyyy · hh:mm a', locale);
    return formatter.format(dateTime);
  }

  static String formatShortDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }
}

