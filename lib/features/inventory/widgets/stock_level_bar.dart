// lib/features/inventory/widgets/stock_level_bar.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/product_model.dart';

class StockLevelBar extends StatelessWidget {
  final ProductModel product;
  const StockLevelBar({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final max   = (product.minStockLevel * 3).clamp(10, 9999);
    final ratio = (product.quantity / max).clamp(0.0, 1.0);
    final color = product.isOutOfStock
        ? AppColors.danger
        : product.isLowStock
            ? AppColors.warning
            : AppColors.success;

    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value:           ratio,
        minHeight:       6,
        backgroundColor: color.withOpacity(0.15),
        valueColor:      AlwaysStoppedAnimation(color),
      ),
    );
  }
}
