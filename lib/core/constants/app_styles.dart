// lib/core/constants/app_styles.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Reusable TextStyles & BoxDecorations
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';

class AppStyles {
  AppStyles._();

  // ── Headings ───────────────────────────────────────────────
  static const TextStyle h1 = TextStyle(
    fontSize: AppDimensions.fontH1,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: AppDimensions.fontH2,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: AppDimensions.fontH3,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: AppDimensions.fontXxl,
    fontWeight: FontWeight.w600,
  );

  // ── Body ───────────────────────────────────────────────────
  static const TextStyle bodyLg = TextStyle(
    fontSize: AppDimensions.fontXl,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle body = TextStyle(
    fontSize: AppDimensions.fontBase,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodySm = TextStyle(
    fontSize: AppDimensions.fontMd,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle caption = TextStyle(
    fontSize: AppDimensions.fontSm,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
  );

  static const TextStyle label = TextStyle(
    fontSize: AppDimensions.fontSm,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle overline = TextStyle(
    fontSize: AppDimensions.fontXs,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
  );

  // ── Stat Numbers ───────────────────────────────────────────
  static const TextStyle statValue = TextStyle(
    fontSize: AppDimensions.fontH2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: AppDimensions.fontSm,
    fontWeight: FontWeight.w500,
  );

  // ── Price ──────────────────────────────────────────────────
  static TextStyle price({Color? color}) => TextStyle(
    fontSize: AppDimensions.fontXl,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.primary,
    letterSpacing: -0.3,
  );

  static TextStyle priceLg({Color? color}) => TextStyle(
    fontSize: AppDimensions.fontH2,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.primary,
    letterSpacing: -0.5,
  );

  // ── Button Text ────────────────────────────────────────────
  static const TextStyle btnLabel = TextStyle(
    fontSize: AppDimensions.fontLg,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  // ── Card Decorations ───────────────────────────────────────
  static BoxDecoration cardLight = BoxDecoration(
    color: AppColors.lightCard,
    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
    border: Border.all(color: AppColors.lightBorder),
  );

  static BoxDecoration cardDark = BoxDecoration(
    color: AppColors.darkCard,
    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
    border: Border.all(color: AppColors.darkBorder),
  );

  static BoxDecoration card(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? cardDark : cardLight;
  }

  // ── Gradient Header ────────────────────────────────────────
  static BoxDecoration gradientHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      gradient: LinearGradient(
        colors: isDark
            ? [AppColors.darkCard, const Color(0xFF16213E)]
            : [AppColors.primary, AppColors.primaryLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  // ── Input Decoration ───────────────────────────────────────
  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    Widget? prefix,
    Widget? suffix,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      prefix: prefix,
      suffix: suffix,
    );
  }

  // ── Shadow ─────────────────────────────────────────────────
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get medShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> primaryShadow(double opacity) => [
    BoxShadow(
      color: AppColors.primary.withOpacity(opacity),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];
}
