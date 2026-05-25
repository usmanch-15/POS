// lib/core/utils/date_formatter.dart
// StockPro — Date and time formatting helpers

import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  // 25 May 2026
  static String dateLong(DateTime dt) =>
      DateFormat('dd MMMM yyyy').format(dt);

  // 25 May 26
  static String dateShort(DateTime dt) =>
      DateFormat('dd MMM yy').format(dt);

  // 25/05/2026
  static String dateNumeric(DateTime dt) =>
      DateFormat('dd/MM/yyyy').format(dt);

  // 14:30
  static String time(DateTime dt) =>
      DateFormat('HH:mm').format(dt);

  // 2:30 PM
  static String time12h(DateTime dt) =>
      DateFormat('h:mm a').format(dt);

  // 25 May, 2:30 PM
  static String dateTime(DateTime dt) =>
      DateFormat('dd MMM, h:mm a').format(dt);

  // Monday, 25 May
  static String fullDate(DateTime dt) =>
      DateFormat('EEEE, dd MMMM').format(dt);

  // relative — "2 mins ago"
  static String relative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    if (diff.inDays < 7)     return '${diff.inDays}d ago';
    return dateShort(dt);
  }

  // Check if today
  static bool isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  // Start of day
  static DateTime startOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  // End of day
  static DateTime endOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day, 23, 59, 59);

  // Start of month
  static DateTime startOfMonth(DateTime dt) =>
      DateTime(dt.year, dt.month, 1);

  // End of month
  static DateTime endOfMonth(DateTime dt) =>
      DateTime(dt.year, dt.month + 1, 0, 23, 59, 59);
}