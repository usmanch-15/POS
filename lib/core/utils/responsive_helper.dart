// lib/core/utils/responsive_helper.dart
// StockPro — Responsive breakpoints and helpers

import 'package:flutter/material.dart';

class ResponsiveHelper {
  ResponsiveHelper._();

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
          MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Grid columns based on screen size
  static int gridColumns(BuildContext context) {
    final w = screenWidth(context);
    if (w >= 1200) return 4;
    if (w >= 900)  return 3;
    if (w >= 600)  return 2;
    return 1;
  }

  // Page horizontal padding
  static EdgeInsets pagePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }

  // Responsive value helper
  static T value<T>(BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet ?? desktop;
    return mobile;
  }

  // Font sizes
  static double titleSize(BuildContext context) =>
      value(context, mobile: 20.0, tablet: 24.0, desktop: 28.0);

  static double bodySize(BuildContext context) =>
      value(context, mobile: 13.0, desktop: 15.0);
}