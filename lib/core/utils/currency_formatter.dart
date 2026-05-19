// lib/core/utils/currency_formatter.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Currency & Number Formatting Utilities
// ─────────────────────────────────────────────────────────────

import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String _symbol = 'PKR';

  /// Call once at app start from SettingsProvider
  static void setSymbol(String symbol) => _symbol = symbol;

  /// PKR 1,250.00
  static String format(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '$_symbol ${formatter.format(amount)}';
  }

  /// PKR 1,250 (no decimals — for stat cards)
  static String formatCompact(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '$_symbol ${formatter.format(amount)}';
  }

  /// 1,250.00 (no symbol)
  static String formatNumber(double amount) {
    return NumberFormat('#,##0.00', 'en_US').format(amount);
  }

  /// 1,250 (no symbol, no decimals)
  static String formatInt(int amount) {
    return NumberFormat('#,##0', 'en_US').format(amount);
  }

  /// 1.2K / 1.5M / 2.3B — for big stat numbers
  static String formatAbbreviated(double amount) {
    if (amount >= 1000000000) {
      return '${_symbol} ${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${_symbol} ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${_symbol} ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }

  /// Profit margin % → "24.5%"
  static String formatPercent(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// Parse "1,250.00" → 1250.0
  static double? tryParse(String raw) {
    final cleaned = raw.replaceAll(',', '').replaceAll(_symbol, '').trim();
    return double.tryParse(cleaned);
  }

  static String get symbol => _symbol;
}
