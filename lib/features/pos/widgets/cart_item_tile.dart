// lib/features/pos/widgets/cart_item_tile.dart
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
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                Text(CurrencyFormatter.format(item.salePrice),
                    style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkText3
                            : AppColors.lightText3)),
              ],
            ),
          ),
          // Qty controls
          Row(children: [
            _QtyBtn(
              icon: Icons.remove_rounded,
              onTap: () => cart.decrement(item.productId),
            ),
            SizedBox(
              width: 28,
              child: Text('${item.quantity}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            _QtyBtn(
              icon: Icons.add_rounded,
              onTap: () => cart.increment(item.productId),
            ),
          ]),
          const SizedBox(width: 8),
          // Total
          Text(CurrencyFormatter.format(item.total),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
          const SizedBox(width: 4),
          // Delete
          GestureDetector(
            onTap: () => cart.removeItem(item.productId),
            child: const Icon(Icons.close_rounded,
                size: 16, color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: AppColors.primary),
      ),
    );
  }
}
