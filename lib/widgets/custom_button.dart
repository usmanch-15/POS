// lib/widgets/custom_button.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Reusable Button Widget
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';

enum ButtonVariant { primary, secondary, danger, success, outline, ghost }
enum ButtonSize    { sm, md, lg }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool iconTrailing;
  final bool loading;
  final bool fullWidth;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant  = ButtonVariant.primary,
    this.size     = ButtonSize.md,
    this.icon,
    this.iconTrailing = false,
    this.loading  = false,
    this.fullWidth = true,
  });

  // ── Factories ──────────────────────────────────────────────
  const CustomButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.fullWidth = true,
  })  : variant = ButtonVariant.danger,
        size = ButtonSize.md,
        iconTrailing = false;

  const CustomButton.outline({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.fullWidth = true,
  })  : variant = ButtonVariant.outline,
        size = ButtonSize.md,
        iconTrailing = false;

  // ── Style resolution ───────────────────────────────────────
  Color _bgColor(bool isDark) {
    switch (variant) {
      case ButtonVariant.primary:   return AppColors.primary;
      case ButtonVariant.secondary: return isDark ? AppColors.darkSurface : AppColors.lightSurface;
      case ButtonVariant.danger:    return AppColors.danger;
      case ButtonVariant.success:   return AppColors.success;
      case ButtonVariant.outline:   return Colors.transparent;
      case ButtonVariant.ghost:     return Colors.transparent;
    }
  }

  Color _fgColor(bool isDark) {
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.danger:
      case ButtonVariant.success:   return Colors.white;
      case ButtonVariant.secondary: return isDark ? Colors.white : AppColors.lightText1;
      case ButtonVariant.outline:   return AppColors.primary;
      case ButtonVariant.ghost:     return isDark ? AppColors.darkText2 : AppColors.lightText2;
    }
  }

  BorderSide _border(bool isDark) {
    if (variant == ButtonVariant.outline) {
      return const BorderSide(color: AppColors.primary, width: 1.5);
    }
    if (variant == ButtonVariant.secondary) {
      return BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder);
    }
    return BorderSide.none;
  }

  double get _height {
    switch (size) {
      case ButtonSize.sm: return 36;
      case ButtonSize.md: return AppDimensions.buttonHeight;
      case ButtonSize.lg: return 58;
    }
  }

  double get _fontSize {
    switch (size) {
      case ButtonSize.sm: return AppDimensions.fontSm;
      case ButtonSize.md: return AppDimensions.fontLg;
      case ButtonSize.lg: return AppDimensions.fontXl;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = _bgColor(isDark);
    final fg     = _fgColor(isDark);
    final border = _border(isDark);

    Widget child;
    if (loading) {
      child = SizedBox(
        width: 22, height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation(fg),
        ),
      );
    } else if (icon != null) {
      final iconWidget = Icon(icon, size: size == ButtonSize.sm ? 16 : 20, color: fg);
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: iconTrailing
            ? [Text(label, style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w600, color: fg)),
               const SizedBox(width: 8), iconWidget]
            : [iconWidget, const SizedBox(width: 8),
               Text(label, style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w600, color: fg))],
      );
    } else {
      child = Text(label, style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w600, color: fg));
    }

    final btn = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: _height,
      decoration: BoxDecoration(
        color: (onPressed == null && !loading) ? bg.withOpacity(0.5) : bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: border != BorderSide.none ? Border.fromBorderSide(border) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (onPressed == null || loading) ? null : onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Center(child: child),
        ),
      ),
    );

    if (fullWidth) return SizedBox(width: double.infinity, child: btn);
    return btn;
  }
}
