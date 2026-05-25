// lib/providers/theme_provider.dart
// StockPro — Theme Mode Provider

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _key = 'isDarkMode';
  ThemeMode _mode   = ThemeMode.dark;

  ThemeMode get themeMode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  ThemeProvider() {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final prefs  = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_key) ?? true;
    _mode        = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggle() async {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDark);
  }

  Future<void> setDark(bool dark) async {
    _mode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, dark);
  }
}