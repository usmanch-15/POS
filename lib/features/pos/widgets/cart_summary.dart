// lib/features/pos/widgets/cart_summary.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/cart_provider.dart';

class CartSummary extends StatelessWidget {
  final CartProvider cart;
  const CartSummary({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Column(children: [
        _row('Subtotal', CurrencyFormatter.format(cart.subtotal), isDark),
        if (cart.discountAmount > 0)
          _row('Discount',
              '- ${CurrencyFormatter.format(cart.discountAmount)}', isDark,
              color: AppColors.danger),
        if (cart.taxRate > 0)
          _row('Tax (${cart.taxRate}%)',
              CurrencyFormatter.format(cart.taxAmount), isDark),
        const Divider(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            Text(CurrencyFormatter.format(cart.grandTotal),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ],
        ),
      ]),
    );
  }

  Widget _row(String label, String value, bool isDark, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color:
                      isDark ? AppColors.darkText2 : AppColors.lightText2)),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}
