// lib/providers/theme_provider.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Theme Provider (ChangeNotifier)
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark;

  ThemeProvider() : _isDark = LocalStorageService.isDarkMode;

  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    await LocalStorageService.setDarkMode(_isDark);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDark == value) return;
    _isDark = value;
    await LocalStorageService.setDarkMode(_isDark);
    notifyListeners();
  }
}
