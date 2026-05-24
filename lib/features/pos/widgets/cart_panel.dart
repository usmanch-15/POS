// lib/features/pos/widgets/cart_panel.dart
// StockPro — Premium Cart Panel

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';
import 'cart_item_tile.dart';
import 'payment_dialog.dart';

class CartPanel extends StatelessWidget {
  final VoidCallback? onBack;
  const CartPanel({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart   = context.watch<CartProvider>();
    final auth   = context.watch<AuthProvider>();

    return Container(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: Row(
              children: [
                if (onBack != null) ...[
                  GestureDetector(
                    onTap: onBack,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightElevated,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                const Expanded(
                  child: Text('Cart',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                if (cart.itemCount > 0)
                  GestureDetector(
                    onTap: () => _confirmClear(context, cart),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Clear',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.danger)),
                    ),
                  ),
              ],
            ),
          ),

          // Cart items
          Expanded(
            child: cart.items.isEmpty
                ? const PremiumEmptyState.cart()
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cart.items.length,
              itemBuilder: (_, i) =>
                  CartItemTile(item: cart.items[i]),
            ),
          ),

          // Summary + checkout
          if (cart.items.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'Subtotal',
                    value: CurrencyFormatter.format(cart.subtotal),
                    isDark: isDark,
                  ),
                  if (cart.discountAmount > 0)
                    _SummaryRow(
                      label: 'Discount',
                      value: '- ${CurrencyFormatter.format(cart.discountAmount)}',
                      valueColor: AppColors.danger,
                      isDark: isDark,
                    ),
                  if (cart.taxRate > 0)
                    _SummaryRow(
                      label: 'Tax (${cart.taxRate}%)',
                      value: CurrencyFormatter.format(cart.taxAmount),
                      isDark: isDark,
                    ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      Text(
                        CurrencyFormatter.format(cart.grandTotal),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: GradientButton(
                label: 'Proceed to Payment',
                icon: Icons.payment_rounded,
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => PaymentDialog(
                    cashierId: auth.user?.id,
                    cashierName: auth.user?.name,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Remove all items from cart?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              cart.clear();
              Navigator.pop(context);
            },
            child: const Text('Clear',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isDark;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkText3 : AppColors.lightText3)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ??
                      (isDark ? AppColors.darkText1 : AppColors.lightText1))),
        ],
      ),
    );
  }
}