// lib/core/utils/date_formatter.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Date & Time Formatting Utilities
// ─────────────────────────────────────────────────────────────

import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  // ── Formatters ─────────────────────────────────────────────
  static final _dateShort   = DateFormat('dd MMM yyyy');       // 05 Jan 2025
  static final _dateLong    = DateFormat('EEEE, dd MMMM yyyy');// Monday, 05 January 2025
  static final _time        = DateFormat('hh:mm a');           // 03:45 PM
  static final _dateTime    = DateFormat('dd MMM yyyy  hh:mm a');
  static final _monthYear   = DateFormat('MMMM yyyy');         // January 2025
  static final _dayMonth    = DateFormat('dd MMM');            // 05 Jan
  static final _isoDate     = DateFormat('yyyy-MM-dd');        // 2025-01-05

  /// 05 Jan 2025
  static String dateShort(DateTime dt) => _dateShort.format(dt);

  /// Monday, 05 January 2025
  static String dateLong(DateTime dt) => _dateLong.format(dt);

  /// 03:45 PM
  static String time(DateTime dt) => _time.format(dt);

  /// 05 Jan 2025  03:45 PM
  static String dateTime(DateTime dt) => _dateTime.format(dt);

  /// January 2025
  static String monthYear(DateTime dt) => _monthYear.format(dt);

  /// 05 Jan
  static String dayMonth(DateTime dt) => _dayMonth.format(dt);

  /// 2025-01-05
  static String iso(DateTime dt) => _isoDate.format(dt);

  /// "Just now" / "2 hrs ago" / "05 Jan 2025"
  static String relative(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60)  return 'Just now';
    if (diff.inMinutes < 60)  return '${diff.inMinutes} min ago';
    if (diff.inHours < 24)    return '${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays == 1)     return 'Yesterday';
    if (diff.inDays < 7)      return '${diff.inDays} days ago';
    return dateShort(dt);
  }

  /// Today / Yesterday / 05 Jan 2025
  static String friendly(DateTime dt) {
    final now = DateTime.now();
    if (_isSameDay(dt, now))                       return 'Today';
    if (_isSameDay(dt, now.subtract(const Duration(days: 1)))) return 'Yesterday';
    return dateShort(dt);
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isToday(DateTime dt) => _isSameDay(dt, DateTime.now());

  /// Start of today (00:00:00)
  static DateTime startOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  /// End of today (23:59:59)
  static DateTime endOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day, 23, 59, 59);

  /// Start of month
  static DateTime startOfMonth(DateTime dt) => DateTime(dt.year, dt.month, 1);

  /// End of month
  static DateTime endOfMonth(DateTime dt) =>
      DateTime(dt.year, dt.month + 1, 0, 23, 59, 59);
}
