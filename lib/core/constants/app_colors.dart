// lib/core/constants/app_colors.dart
// StockPro — Complete Color System (Dark + Light + Gradients)

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────
  static const Color primary      = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF857DFF);
  static const Color primaryDark  = Color(0xFF4F46E5);

  // ── Semantic ─────────────────────────────────────────────
  static const Color success      = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning      = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger       = Color(0xFFEF4444);
  static const Color dangerLight  = Color(0xFFFEE2E2);
  static const Color info         = Color(0xFF38BDF8);
  static const Color infoLight    = Color(0xFFE0F2FE);

  // ── Dark Surfaces ─────────────────────────────────────────
  static const Color darkScaffold = Color(0xFF0B0B14);
  static const Color darkCard     = Color(0xFF13131F);
  static const Color darkSurface  = Color(0xFF1C1C2E);
  static const Color darkElevated = Color(0xFF222235);
  static const Color darkBorder   = Color(0x1AFFFFFF);
  static const Color darkDivider  = Color(0x0DFFFFFF);

  // ── Light Surfaces ────────────────────────────────────────
  static const Color lightScaffold = Color(0xFFF2F4F8);
  static const Color lightCard     = Color(0xFFFFFFFF);
  static const Color lightSurface  = Color(0xFFF8FAFC);
  static const Color lightElevated = Color(0xFFEDF0F7);
  static const Color lightBorder   = Color(0xFFE4E8F0);
  static const Color lightDivider  = Color(0xFFF1F3F8);

  // ── Text Dark ─────────────────────────────────────────────
  static const Color darkText1 = Color(0xFFF1F1FF);
  static const Color darkText2 = Color(0xAAB0B8D4);
  static const Color darkText3 = Color(0x66B0B8D4);

  // ── Text Light ────────────────────────────────────────────
  static const Color lightText1 = Color(0xFF0D0D1A);
  static const Color lightText2 = Color(0xFF4A5568);
  static const Color lightText3 = Color(0xFF9AA5B4);

  // ── Alias (backward-compat) ───────────────────────────────
  static const Color secondary     = primary;
  static const Color textSecondary = lightText2;
  static const Color borderGlow    = Color(0x406C63FF);
  static const Color surface       = darkSurface;
  static const Color border        = darkBorder;
  static const Color textSecond    = darkText2;

  // ── Chart Colors ──────────────────────────────────────────
  static const List<Color> chartColors = [
    Color(0xFF6C63FF), Color(0xFF10B981), Color(0xFFF59E0B),
    Color(0xFFEF4444), Color(0xFF38BDF8), Color(0xFFEC4899),
    Color(0xFF8B5CF6), Color(0xFF14B8A6),
  ];

  // ✅ FIX: category_pie_chart.dart lines 41 — categoryColors add kiya
  static const List<Color> categoryColors = [
    Color(0xFF6C63FF), // purple
    Color(0xFF10B981), // green
    Color(0xFFF59E0B), // amber
    Color(0xFFEF4444), // red
    Color(0xFF38BDF8), // sky blue
    Color(0xFFEC4899), // pink
    Color(0xFF8B5CF6), // violet
    Color(0xFF14B8A6), // teal
  ];

  // ── Gradients ─────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9D6FFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient infoGradient = LinearGradient(
    colors: [Color(0xFF38BDF8), Color(0xFF7DD3FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBgGradient = LinearGradient(
    colors: [Color(0xFF0B0B14), Color(0xFF13131F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Glass decoration helper ───────────────────────────────
  static BoxDecoration glassCard({bool isDark = true}) => BoxDecoration(
    color: isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.white.withOpacity(0.85),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.white.withOpacity(0.6),
    ),
    boxShadow: isDark
        ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]
        : [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 20, offset: const Offset(0, 6))],
  );

  static BoxDecoration cardDecoration({bool isDark = true}) => BoxDecoration(
    color: isDark ? darkCard : lightCard,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: isDark ? darkBorder : lightBorder),
    boxShadow: isDark
        ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))]
        : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
  );
}