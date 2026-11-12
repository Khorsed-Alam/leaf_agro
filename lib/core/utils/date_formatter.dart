import 'package:intl/intl.dart';

class DateFormatter {
  static String formatTimestamp(DateTime dateTime, {String? locale}) {
    try {
      final formatter = locale != null
          ? DateFormat('MMM d, yyyy · hh:mm a', locale)
          : DateFormat('MMM d, yyyy · hh:mm a');
      return formatter.format(dateTime);
    } catch (_) {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final month = months[dateTime.month - 1];
      final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$month ${dateTime.day}, ${dateTime.year} · $hour:$minute $period';
    }
  }

  static String formatShortDate(DateTime dateTime) {
    try {
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (_) {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final month = months[dateTime.month - 1];
      return '${dateTime.day} $month ${dateTime.year}';
    }
  }
}

