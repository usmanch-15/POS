// lib/features/pos/widgets/cart_item_tile.dart
// StockPro — Premium Cart Item Row

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/sale_item_model.dart';
import '../../../providers/cart_provider.dart';

class CartItemTile extends StatelessWidget {
  final SaleItemModel item;
  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart   = context.read<CartProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          // Product icon
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory_2_rounded,
                color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 10),

          // Name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText1 : AppColors.lightText1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.format(item.salePrice),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkText3 : AppColors.lightText3,
                  ),
                ),
              ],
            ),
          ),

          // Qty controls
          Row(
            children: [
              _QtyBtn(
                icon: Icons.remove_rounded,
                onTap: () => cart.decrement(item.productId),
                color: AppColors.danger,
              ),
              Container(
                width: 32,
                alignment: Alignment.center,
                child: Text(
                  '${item.quantity}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText1 : AppColors.lightText1,
                  ),
                ),
              ),
              _QtyBtn(
                icon: Icons.add_rounded,
                onTap: () => cart.increment(item.productId),
                color: AppColors.success,
              ),
            ],
          ),

          const SizedBox(width: 8),

          // Total
          Text(
            CurrencyFormatter.format(item.total),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const _QtyBtn({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26, height: 26,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}