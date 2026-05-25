// lib/features/dashboard/widgets/low_stock_alert.dart
// StockPro — Low Stock Alert List

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../models/product_model.dart';

class LowStockAlert extends StatelessWidget {
  final List<ProductModel> products;
  const LowStockAlert({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return PremiumCard(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 18),
          ),
          const SizedBox(width: 12),
          const Text('All stock levels are healthy!',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.success)),
        ]),
      );
    }

    return Column(
      children: products.take(5).map((p) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final isOut  = p.isOutOfStock;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isOut
                  ? AppColors.danger.withOpacity(0.25)
                  : AppColors.warning.withOpacity(0.3),
            ),
          ),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: (isOut ? AppColors.danger : AppColors.warning)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isOut ? Icons.remove_shopping_cart_rounded
                    : Icons.warning_amber_rounded,
                color: isOut ? AppColors.danger : AppColors.warning,
                size: 17,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkText1 : AppColors.lightText1,
                      ),
                      overflow: TextOverflow.ellipsis),
                  Text(p.category,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkText3 : AppColors.lightText3,
                      )),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (isOut ? AppColors.danger : AppColors.warning)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isOut ? 'Out' : '${p.quantity} left',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isOut ? AppColors.danger : AppColors.warning,
                ),
              ),
            ),
          ]),
        );
      }).toList(),
    );
  }
}