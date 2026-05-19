// lib/core/utils/responsive_helper.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Responsive Layout Helpers
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class ResponsiveHelper {
  ResponsiveHelper._();

  // ── Breakpoints ────────────────────────────────────────────
  static const double _mobileMax  = 600;
  static const double _tabletMax  = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < _mobileMax;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= _mobileMax && w < _tabletMax;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= _tabletMax;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // ── Grid Columns ───────────────────────────────────────────
  static int gridColumns(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context))  return 3;
    return 2;
  }

  static int statCardColumns(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context))  return 4;
    return 2;
  }

  // ── Adaptive Padding ───────────────────────────────────────
  static EdgeInsets pagePadding(BuildContext context) {
    if (isDesktop(context)) return const EdgeInsets.all(24);
    if (isTablet(context))  return const EdgeInsets.all(20);
    return const EdgeInsets.all(16);
  }

  // ── Adaptive Font Size ─────────────────────────────────────
  static double fontSize(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? (mobile + 4);
    if (isTablet(context))  return tablet  ?? (mobile + 2);
    return mobile;
  }

  // ── Value by size ──────────────────────────────────────────
  static T value<T>(BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context))  return tablet  ?? mobile;
    return mobile;
  }
}
