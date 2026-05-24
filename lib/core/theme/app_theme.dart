// lib/core/theme/app_theme.dart
// StockPro — Material 3 Premium Theme (Light + Dark)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static const String _fontFamily = 'Inter';

  // ─── Light Theme ────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: _fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: AppColors.lightCard,
      onSurface: AppColors.lightText1,
      background: AppColors.lightScaffold,
    ),
    scaffoldBackgroundColor: AppColors.lightScaffold,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightCard,
      foregroundColor: AppColors.lightText1,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.lightText1,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: AppColors.lightText1, size: 22),
    ),

    // Cards
    cardTheme: CardThemeData(
      color: AppColors.lightCard,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
    ),

    // Input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      labelStyle: const TextStyle(color: AppColors.lightText3, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.lightText3, fontSize: 14),
    ),

    // Elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // Text button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // Outlined button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedColor: AppColors.primary.withOpacity(0.15),
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
      side: const BorderSide(color: AppColors.lightBorder),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.lightDivider,
      space: 1,
      thickness: 1,
    ),

    // Bottom nav
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.lightCard,
      indicatorColor: AppColors.primary.withOpacity(0.12),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary);
        }
        return const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.lightText3);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 22);
        }
        return const IconThemeData(color: AppColors.lightText3, size: 22);
      }),
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentTextStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    // Bottom sheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );

  // ─── Dark Theme ─────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: _fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: AppColors.darkCard,
      onSurface: AppColors.darkText1,
      background: AppColors.darkScaffold,
    ),
    scaffoldBackgroundColor: AppColors.darkScaffold,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkCard,
      foregroundColor: AppColors.darkText1,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText1,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: AppColors.darkText1, size: 22),
    ),

    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      labelStyle: const TextStyle(color: AppColors.darkText3, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.darkText3, fontSize: 14),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.darkText1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
      side: const BorderSide(color: AppColors.darkBorder),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
      space: 1,
      thickness: 1,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.darkCard,
      indicatorColor: AppColors.primary.withOpacity(0.18),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary);
        }
        return TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.darkText3);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 22);
        }
        return IconThemeData(color: AppColors.darkText3, size: 22);
      }),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkElevated,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentTextStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.darkText1),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );
}