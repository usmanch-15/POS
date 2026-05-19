// lib/features/pos/widgets/product_tile.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/product_model.dart';
import '../../../providers/cart_provider.dart';

class ProductTile extends StatelessWidget {
  final ProductModel product;
  const ProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final cart      = context.read<CartProvider>();
    final isOutOfStock = product.isOutOfStock;

    return GestureDetector(
      onTap: isOutOfStock
          ? null
          : () {
              cart.addProduct(product);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text('${product.name} added'),
                  duration: const Duration(milliseconds: 800),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ));
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isOutOfStock
              ? (isDark
                  ? AppColors.darkSurface.withOpacity(0.5)
                  : AppColors.lightSurface)
              : (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Category chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(product.category,
                  style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
            ),

            // Name
            Text(
              product.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isOutOfStock
                    ? (isDark ? AppColors.darkText3 : AppColors.lightText3)
                    : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Price + stock
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CurrencyFormatter.format(product.salePrice),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
                ),
                Text(
                  isOutOfStock ? 'Out' : '${product.quantity}',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isOutOfStock
                          ? AppColors.danger
                          : product.isLowStock
                              ? AppColors.warning
                              : AppColors.success),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
