// lib/core/constants/app_colors.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Centralized Color Palette
//  All colors sourced from AppTheme — single source of truth
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────
  static const Color primary       = Color(0xFF6C63FF);
  static const Color primaryLight  = Color(0xFF857DFF);
  static const Color primaryDark   = Color(0xFF4F46E5);

  // ── Semantic ───────────────────────────────────────────────
  static const Color success       = Color(0xFF22C55E);
  static const Color successLight  = Color(0xFFDCFCE7);
  static const Color warning       = Color(0xFFF59E0B);
  static const Color warningLight  = Color(0xFFFEF3C7);
  static const Color danger        = Color(0xFFEF4444);
  static const Color dangerLight   = Color(0xFFFEE2E2);
  static const Color info          = Color(0xFF38BDF8);
  static const Color infoLight     = Color(0xFFE0F2FE);

  // ── Dark Mode Surfaces ─────────────────────────────────────
  static const Color darkScaffold  = Color(0xFF0F0F1A);
  static const Color darkCard      = Color(0xFF1A1A2E);
  static const Color darkSurface   = Color(0xFF252540);
  static const Color darkBorder    = Color(0x1FFFFFFF); // white12

  // ── Light Mode Surfaces ────────────────────────────────────
  static const Color lightScaffold = Color(0xFFF1F5FB);
  static const Color lightCard     = Colors.white;
  static const Color lightSurface  = Color(0xFFF8FAFC);
  static const Color lightBorder   = Color(0xFFE2E8F0);

  // ── Text — Dark ────────────────────────────────────────────
  static const Color darkText1     = Colors.white;
  static const Color darkText2     = Color(0xB3FFFFFF); // white70
  static const Color darkText3     = Color(0x61FFFFFF); // white38

  // ── Text — Light ───────────────────────────────────────────
  static const Color lightText1    = Color(0xFF0F172A);
  static const Color lightText2    = Color(0xFF475569);
  static const Color lightText3    = Color(0xFF94A3B8);

  // ── Category Chip Colors ───────────────────────────────────
  static const List<Color> categoryColors = [
    Color(0xFF6C63FF),
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF38BDF8),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
  ];

  // ── Chart Colors ───────────────────────────────────────────
  static const List<Color> chartColors = [
    Color(0xFF6C63FF),
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF38BDF8),
    Color(0xFFEC4899),
  ];

  // ── Gradient Presets ───────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
