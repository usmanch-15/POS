// lib/features/products/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/product_model.dart';
import '../../../providers/product_provider.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/status_badge.dart';
import '../add_product_screen.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(children: [
        // Icon
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.inventory_2_outlined,
              color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(product.category,
                  style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkText3
                          : AppColors.lightText3)),
              const SizedBox(height: 6),
              Row(children: [
                Text(CurrencyFormatter.format(product.salePrice),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
                const SizedBox(width: 8),
                StatusBadge.fromStockStatus(product.stockStatus.key),
              ]),
            ],
          ),
        ),

        // Stock qty
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${product.quantity}',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: product.isOutOfStock
                        ? AppColors.danger
                        : product.isLowStock
                            ? AppColors.warning
                            : AppColors.success)),
            Text('units',
                style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? AppColors.darkText3
                        : AppColors.lightText3)),
            const SizedBox(height: 4),
            Row(children: [
              // Edit
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddProductScreen(product: product),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      size: 14, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 6),
              // Delete
              GestureDetector(
                onTap: () async {
                  final ok = await ConfirmDialog.show(
                    context,
                    title:   'Delete Product',
                    message:
                        'Delete "${product.name}"? This cannot be undone.',
                  );
                  if (ok && context.mounted) {
                    context
                        .read<ProductProvider>()
                        .deleteProduct(product.id);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      size: 14, color: AppColors.danger),
                ),
              ),
            ]),
          ],
        ),
      ]),
    );
  }
}
