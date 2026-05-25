// lib/features/inventory/widgets/stock_level_bar.dart
// StockPro — Animated Stock Level Progress Bar

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/product_model.dart';

class StockLevelBar extends StatefulWidget {
  final ProductModel product;
  const StockLevelBar({super.key, required this.product});

  @override
  State<StockLevelBar> createState() => _StockLevelBarState();
}

class _StockLevelBarState extends State<StockLevelBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  double get _level {
    final max = (widget.product.minStockLevel * 3).toDouble();
    final cur = widget.product.quantity.toDouble();
    return (cur / max).clamp(0.0, 1.0);
  }

  Color get _barColor {
    if (widget.product.isOutOfStock) return AppColors.danger;
    if (widget.product.isLowStock)   return AppColors.warning;
    return AppColors.success;
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _anim = Tween<double>(begin: 0, end: _level)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stock Level',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.darkText3 : AppColors.lightText3,
                  ),
                ),
                Text(
                  '${widget.product.quantity} / ${widget.product.minStockLevel * 3}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _barColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              height: 5,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface
                    : AppColors.lightElevated,
                borderRadius: BorderRadius.circular(3),
              ),
              child: AnimatedBuilder(
                animation: _anim,
                builder: (_, __) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _anim.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _barColor,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: _barColor.withOpacity(0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}