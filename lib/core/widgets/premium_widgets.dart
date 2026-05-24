// lib/core/widgets/premium_widgets.dart
// StockPro — Premium Reusable Widget Library

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

// ─── Premium Card ────────────────────────────────────────────
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool glass;
  final LinearGradient? gradient;
  final Color? color;
  final double radius;
  final List<BoxShadow>? shadow;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.glass = false,
    this.gradient,
    this.color,
    this.radius = 16,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = color ?? (isDark ? AppColors.darkCard : AppColors.lightCard);

    Widget card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null
            ? (glass
            ? (isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.8))
            : bgColor)
            : null,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: glass
              ? (isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.5))
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: glass ? 1 : 1,
        ),
        boxShadow: shadow ??
            (gradient != null
                ? [
              BoxShadow(
                color: (gradient!.colors.first).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 6),
              )
            ]
                : isDark
                ? [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 3))]
                : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 3))]),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: card,
      );
    }
    return card;
  }
}

// ─── Gradient Button ─────────────────────────────────────────
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final LinearGradient? gradient;
  final double? width;
  final double height;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.gradient,
    this.width,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final grad = gradient ?? AppColors.primaryGradient;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed == null
              ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade300])
              : grad,
          borderRadius: BorderRadius.circular(12),
          boxShadow: onPressed == null
              ? []
              : [BoxShadow(color: grad.colors.first.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 5))],
        ),
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: loading
              ? const SizedBox(
            width: 22, height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Text(label,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── App Text Field ──────────────────────────────────────────
class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefix;
  final String? suffix;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.onChanged,
    this.onTap,
    this.inputFormatters,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
    this.enabled = true,
  });

  factory AppTextField.number({
    Key? key,
    required String label,
    String? hint,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    String? prefix,
    String? suffix,
  }) => AppTextField(
    key: key,
    label: label,
    hint: hint ?? '0.00',
    controller: controller,
    validator: validator,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
    onChanged: onChanged,
    prefix: prefix,
    suffix: suffix,
  );

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = false;
  late FocusNode _focus;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    _focus = widget.focusNode ?? FocusNode();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _focused
                  ? AppColors.primary
                  : (isDark ? AppColors.darkText2 : AppColors.lightText2),
            )),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: _obscure,
          readOnly: widget.readOnly,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          inputFormatters: widget.inputFormatters,
          focusNode: _focus,
          textInputAction: widget.textInputAction,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkText1 : AppColors.lightText1,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            prefix: widget.prefix != null ? Text(widget.prefix!) : null,
            suffix: widget.suffix != null ? Text(widget.suffix!) : null,
            suffixIcon: widget.obscureText
                ? IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: isDark ? AppColors.darkText3 : AppColors.lightText3,
                size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            )
                : widget.suffixIcon,
          ),
        ),
      ],
    );
  }
}

// ─── Section Header ──────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText1 : AppColors.lightText1,
                letterSpacing: -0.2,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─── Premium Empty State ─────────────────────────────────────
class PremiumEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const PremiumEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  const PremiumEmptyState.products({super.key, this.onAction})
      : icon = Icons.inventory_2_outlined,
        title = 'No Products Yet',
        subtitle = 'Add your first product to get started',
        actionLabel = 'Add Product',
        iconColor = AppColors.primary;

  const PremiumEmptyState.sales({super.key, this.onAction})
      : icon = Icons.receipt_long_outlined,
        title = 'No Sales Today',
        subtitle = 'Start billing to see sales appear here',
        actionLabel = 'New Bill',
        iconColor = AppColors.success;

  const PremiumEmptyState.search({super.key, this.onAction})
      : icon = Icons.search_off_rounded,
        title = 'No Results Found',
        subtitle = 'Try a different keyword or filter',
        actionLabel = null,
        iconColor = AppColors.info;

  const PremiumEmptyState.cart({super.key, this.onAction})
      : icon = Icons.shopping_cart_outlined,
        title = 'Cart is Empty',
        subtitle = 'Scan a barcode or search a product',
        actionLabel = null,
        iconColor = AppColors.primary;

  const PremiumEmptyState.reports({super.key, this.onAction})
      : icon = Icons.bar_chart_outlined,
        title = 'No Data Yet',
        subtitle = 'Data will appear after you make sales',
        actionLabel = null,
        iconColor = AppColors.warning;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = iconColor ?? AppColors.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText1 : AppColors.lightText1,
                )),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkText3 : AppColors.lightText3,
                    height: 1.5,
                  )),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              GradientButton(
                label: actionLabel!,
                onPressed: onAction,
                width: 160,
                height: 44,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Premium Loading ─────────────────────────────────────────
class PremiumLoader extends StatelessWidget {
  final String? message;
  const PremiumLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 40, height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 14),
            Text(message!,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkText3
                      : AppColors.lightText3,
                )),
          ],
        ],
      ),
    );
  }
}

// ─── Shimmer Loader ──────────────────────────────────────────
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = 8,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
    _anim = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.darkSurface : AppColors.lightElevated;
    final highlight = isDark ? AppColors.darkElevated : Colors.white;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value + 1, 0),
            colors: [base, highlight, base],
          ),
        ),
      ),
    );
  }
}

// ─── Status Badge ────────────────────────────────────────────
class PremiumBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final bool dot;
  final double fontSize;

  const PremiumBadge({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
    this.dot = false,
    this.fontSize = 11,
  });

  factory PremiumBadge.inStock() => const PremiumBadge(
      label: 'In Stock', color: AppColors.successLight,
      textColor: AppColors.success, dot: true);

  factory PremiumBadge.lowStock() => const PremiumBadge(
      label: 'Low Stock', color: AppColors.warningLight,
      textColor: AppColors.warning, dot: true);

  factory PremiumBadge.outOfStock() => const PremiumBadge(
      label: 'Out of Stock', color: AppColors.dangerLight,
      textColor: AppColors.danger, dot: true);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(
                color: textColor ?? Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? Colors.white)),
        ],
      ),
    );
  }
}

// ─── Info Row ─────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkText3 : AppColors.lightText3,
            )),
        Text(value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? (isDark ? AppColors.darkText1 : AppColors.lightText1),
            )),
      ],
    );
  }
}