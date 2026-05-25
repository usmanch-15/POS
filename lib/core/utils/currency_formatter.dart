// lib/core/utils/currency_formatter.dart
// StockPro — Currency formatting helper

import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String _symbol = 'Rs.';
  static String _locale = 'en_PK';

  static void configure({String symbol = 'Rs.', String locale = 'en_PK'}) {
    _symbol = symbol;
    _locale = locale;
  }

  // Main formatter — Rs. 1,234.00
  static String format(double amount) {
    final formatter = NumberFormat('#,##0.00', _locale);
    return '$_symbol ${formatter.format(amount)}';
  }

  // Compact — Rs. 1.2K
  static String compact(double amount) {
    if (amount >= 1000000) {
      return '$_symbol ${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '$_symbol ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }

  // No symbol — 1,234.00
  static String plain(double amount) {
    final formatter = NumberFormat('#,##0.00', _locale);
    return formatter.format(amount);
  }

  // Integer — Rs. 1,234
  static String integer(double amount) {
    final formatter = NumberFormat('#,##0', _locale);
    return '$_symbol ${formatter.format(amount)}';
  }
}