// lib/features/dashboard/widgets/low_stock_alert.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/product_model.dart';

class LowStockAlert extends StatelessWidget {
  final List<ProductModel> products;
  const LowStockAlert({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warningLight),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length.clamp(0, 5),
        separatorBuilder: (_, __) => Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        itemBuilder: (_, i) {
          final p = products[i];
          final isOut = p.isOutOfStock;
          return ListTile(
            dense: true,
            leading: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: (isOut ? AppColors.danger : AppColors.warning)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isOut
                    ? Icons.remove_shopping_cart_outlined
                    : Icons.warning_amber_rounded,
                size: 18,
                color: isOut ? AppColors.danger : AppColors.warning,
              ),
            ),
            title: Text(p.name,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
            subtitle: Text(p.category,
                style: TextStyle(
                    fontSize: 11,
                    color:
                        isDark ? AppColors.darkText3 : AppColors.lightText3)),
            trailing: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (isOut ? AppColors.danger : AppColors.warning)
                    .withOpacity(0.12),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '${p.quantity} left',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isOut ? AppColors.danger : AppColors.warning),
              ),
            ),
          );
        },
      ),
    );
  }
}
