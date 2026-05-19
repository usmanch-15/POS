// lib/features/pos/widgets/cart_panel.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/empty_state.dart';
import 'cart_item_tile.dart';
import 'cart_summary.dart';
import 'payment_dialog.dart';

class CartPanel extends StatelessWidget {
  const CartPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart   = context.watch<CartProvider>();

    return Container(
      color: isDark ? AppColors.darkCard : Colors.white,
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Cart (${cart.itemCount})',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const Spacer(),
                if (!cart.isEmpty)
                  TextButton(
                    onPressed: () async {
                      final ok = await ConfirmDialog.show(
                        context,
                        title:   'Clear Cart',
                        message: 'Remove all items from cart?',
                      );
                      if (ok) cart.clearCart();
                    },
                    child: const Text('Clear',
                        style: TextStyle(color: AppColors.danger)),
                  ),
              ],
            ),
          ),

          // ── Items ────────────────────────────────────────
          Expanded(
            child: cart.isEmpty
                ? const EmptyState.cart()
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: cart.items.length,
                    itemBuilder: (_, i) =>
                        CartItemTile(item: cart.items[i]),
                  ),
          ),

          // ── Summary + Pay ────────────────────────────────
          if (!cart.isEmpty) ...[
            CartSummary(cart: cart),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _showPaymentDialog(context, cart),
                  icon: const Icon(Icons.payment_rounded, size: 20),
                  label: Text(
                    'Pay ${CurrencyFormatter.format(cart.grandTotal)}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, CartProvider cart) {
    final auth = context.read<AuthProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: cart,
        child: PaymentDialog(
          cashierId:   auth.user?.id,
          cashierName: auth.user?.name,
        ),
      ),
    );
  }
}
