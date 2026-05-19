// lib/features/inventory/widgets/low_stock_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/product_model.dart';
import '../stock_adjustment_screen.dart';

class LowStockList extends StatelessWidget {
  final List<ProductModel> products;
  const LowStockList({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dangerLight),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        separatorBuilder: (_, __) => Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        itemBuilder: (_, i) {
          final p     = products[i];
          final isOut = p.isOutOfStock;
          return ListTile(
            dense: true,
            leading: Icon(
              isOut ? Icons.remove_shopping_cart_outlined
                    : Icons.warning_amber_rounded,
              color: isOut ? AppColors.danger : AppColors.warning,
              size: 20,
            ),
            title: Text(p.name,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
            subtitle: Text('${p.quantity} left  •  Min: ${p.minStockLevel}',
                style: const TextStyle(fontSize: 11)),
            trailing: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => StockAdjustmentScreen(product: p)),
              ),
              child: const Text('Stock In',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.primary)),
            ),
          );
        },
      ),
    );
  }
}
