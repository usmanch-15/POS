// lib/core/utils/barcode_helper.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Barcode Validation & Generation Utilities
// ─────────────────────────────────────────────────────────────

import 'dart:math';

class BarcodeHelper {
  BarcodeHelper._();

  // ── Validation ─────────────────────────────────────────────

  /// Validates EAN-13 check digit
  static bool isValidEan13(String code) {
    if (code.length != 13) return false;
    if (!RegExp(r'^\d+$').hasMatch(code)) return false;
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      final digit = int.parse(code[i]);
      sum += i.isEven ? digit : digit * 3;
    }
    final checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(code[12]);
  }

  /// Validates generic numeric barcode (8–14 digits)
  static bool isValidBarcode(String code) {
    if (code.isEmpty) return false;
    if (!RegExp(r'^\d+$').hasMatch(code)) return false;
    return code.length >= 8 && code.length <= 14;
  }

  // ── Generation ─────────────────────────────────────────────

  /// Generate a random 13-digit EAN-compatible barcode
  static String generateEan13() {
    final rng = Random();
    final digits = List<int>.generate(12, (_) => rng.nextInt(10));
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += i.isEven ? digits[i] : digits[i] * 3;
    }
    final check = (10 - (sum % 10)) % 10;
    digits.add(check);
    return digits.join();
  }

  /// Generate sequential internal SKU: SP-00001
  static String generateSku({int number = 1}) {
    return 'SP-${number.toString().padLeft(5, '0')}';
  }

  // ── Formatting ─────────────────────────────────────────────

  /// Format EAN-13 for display: "123 4567 89012 3"
  static String formatEan13(String code) {
    if (code.length != 13) return code;
    return '${code.substring(0, 3)} ${code.substring(3, 7)} ${code.substring(7, 12)} ${code.substring(12)}';
  }

  /// Strip all non-numeric characters from a scanned string
  static String sanitize(String raw) =>
      raw.replaceAll(RegExp(r'[^\d]'), '');
}
