import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/sale_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/report_provider.dart';
import '../../../providers/sale_provider.dart';
import 'receipt_dialog.dart';

class CartPanel extends StatefulWidget {
  const CartPanel({super.key});

  @override
  State<CartPanel> createState() => _CartPanelState();
}

class _CartPanelState extends State<CartPanel> {
  PaymentMethod _paymentMethod  = PaymentMethod.cash;
  final _cashCtrl               = TextEditingController();
  final _discountCtrl           = TextEditingController();
  final _noteCtrl               = TextEditingController();
  bool  _showExtraFields        = false;

  @override
  void dispose() {
    _cashCtrl.dispose();
    _discountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── Checkout ───────────────────────────────────────────────
  Future<void> _checkout(CartProvider cart) async {
    if (cart.isEmpty) {
      _snack('Cart khali hai — pehle products add karein', isError: true);
      return;
    }

    // Cash validation
    if (_paymentMethod == PaymentMethod.cash) {
      final cash = double.tryParse(_cashCtrl.text) ?? 0;
      if (cash < cart.grandTotal) {
        _snack('Cash kam hai — PKR ${CurrencyFormatter.format(cart.grandTotal)} chahiye', isError: true);
        return;
      }
    }

    // Discount apply karo
    final discount = double.tryParse(_discountCtrl.text) ?? 0;
    if (discount > 0) cart.setDiscount(discount);

    final sale = await cart.checkout(
      paymentMethod: _paymentMethod,
      cashReceived:  double.tryParse(_cashCtrl.text) ?? cart.grandTotal,
      note:          _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    if (!mounted) return;

    if (sale != null) {
      // ✅ ReportProvider refresh — dashboard update hoga
      context.read<ReportProvider>().loadDashboardData();
      // ✅ SaleProvider stream already update hoga — but force karo
      context.read<SaleProvider>().loadSales();

      _cashCtrl.clear();
      _discountCtrl.clear();
      _noteCtrl.clear();
      setState(() {
        _paymentMethod   = PaymentMethod.cash;
        _showExtraFields = false;
      });

      // Receipt dialog
      if (mounted) {
        showModalBottomSheet(
          context:       context,
          isScrollControlled: true,
          backgroundColor:    Colors.transparent,
          builder: (_) => ReceiptDialog(sale: sale),
        );
      }
    } else {
      _snack(cart.error ?? 'Kuch masla aa gaya — dobara try karein', isError: true);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:         Text(msg),
      backgroundColor: isError ? AppColors.danger : AppColors.success,
      behavior:        SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart   = context.watch<CartProvider>();

    return Container(
      color: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      child: Column(children: [
        // ── Header ────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          color:   isDark ? AppColors.darkCard : Colors.white,
          child: Row(children: [
            const Icon(Icons.shopping_cart_rounded,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Text('Cart',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const Spacer(),
            if (!cart.isEmpty)
              TextButton.icon(
                onPressed: () {
                  cart.clearCart();
                  _cashCtrl.clear();
                  _discountCtrl.clear();
                },
                icon:  const Icon(Icons.delete_outline,
                    size: 16, color: AppColors.danger),
                label: const Text('Clear',
                    style: TextStyle(color: AppColors.danger, fontSize: 12)),
              ),
            // Item count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color:        AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text('${cart.itemCount} items',
                  style: const TextStyle(
                      color:      AppColors.primary,
                      fontSize:   11,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
        ),

        // ── Cart Items ────────────────────────────────────
        Expanded(
          child: cart.isEmpty
              ? _EmptyCart()
              : ListView.separated(
            padding:          const EdgeInsets.all(12),
            itemCount:        cart.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _CartItem(
              item:   cart.items[i],
              isDark: isDark,
              onIncrement: () =>
                  cart.increment(cart.items[i].productId),
              onDecrement: () =>
                  cart.decrement(cart.items[i].productId),
              onRemove: () =>
                  cart.removeItem(cart.items[i].productId),
            ),
          ),
        ),

        // ── Payment Section ───────────────────────────────
        if (!cart.isEmpty)
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              boxShadow: [
                BoxShadow(
                  color:      Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset:     const Offset(0, -4),
                ),
              ],
            ),
            child: Column(children: [
              // Extra fields toggle
              InkWell(
                onTap: () =>
                    setState(() => _showExtraFields = !_showExtraFields),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Row(children: [
                    Text('Discount & Note',
                        style: TextStyle(
                            fontSize:   12,
                            color:      isDark
                                ? Colors.white54
                                : Colors.black45)),
                    const Spacer(),
                    Icon(
                      _showExtraFields
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 18,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ]),
                ),
              ),

              if (_showExtraFields) ...[
                // Discount
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: TextField(
                    controller:   _discountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: InputDecoration(
                      labelText:  'Discount (PKR)',
                      prefixIcon: const Icon(Icons.local_offer_outlined,
                          size: 18),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                    onChanged: (v) {
                      final d = double.tryParse(v) ?? 0;
                      cart.setDiscount(d);
                    },
                  ),
                ),
                // Note
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: TextField(
                    controller: _noteCtrl,
                    decoration: InputDecoration(
                      labelText:  'Note (optional)',
                      prefixIcon: const Icon(Icons.note_outlined, size: 18),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                  ),
                ),
              ],

              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(children: [

                  // Payment method
                  Row(children: [
                    _PayBtn(
                      label:    'Cash',
                      icon:     Icons.money,
                      selected: _paymentMethod == PaymentMethod.cash,
                      onTap: () => setState(
                              () => _paymentMethod = PaymentMethod.cash),
                    ),
                    const SizedBox(width: 8),
                    _PayBtn(
                      label:    'Card',
                      icon:     Icons.credit_card,
                      selected: _paymentMethod == PaymentMethod.card,
                      onTap: () => setState(
                              () => _paymentMethod = PaymentMethod.card),
                    ),
                    const SizedBox(width: 8),
                    _PayBtn(
                      label:    'Split',
                      icon:     Icons.call_split,
                      selected: _paymentMethod == PaymentMethod.split,
                      onTap: () => setState(
                              () => _paymentMethod = PaymentMethod.split),
                    ),
                  ]),
                  const SizedBox(height: 12),

                  // Cash received field
                  if (_paymentMethod == PaymentMethod.cash) ...[
                    TextField(
                      controller:   _cashCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        labelText:  'Cash Received',
                        prefixText: 'PKR ',
                        prefixIcon: const Icon(Icons.payments_outlined,
                            size: 18),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    // Change
                    if (_cashCtrl.text.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Change: ',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black45)),
                          Text(
                            CurrencyFormatter.format(
                                cart.changeFor(
                                    double.tryParse(_cashCtrl.text) ?? 0)),
                            style: const TextStyle(
                                fontSize:   13,
                                fontWeight: FontWeight.w600,
                                color:      AppColors.success),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                  ],

                  // Summary
                  _SummaryRow(
                      label: 'Subtotal',
                      value: CurrencyFormatter.format(cart.subtotal)),
                  if (cart.discountAmount > 0)
                    _SummaryRow(
                      label: 'Discount',
                      value: '- ${CurrencyFormatter.format(cart.discountAmount)}',
                      color: AppColors.danger,
                    ),
                  if (cart.taxAmount > 0)
                    _SummaryRow(
                      label: 'Tax (${cart.taxRate.toStringAsFixed(0)}%)',
                      value: CurrencyFormatter.format(cart.taxAmount),
                    ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL',
                          style: TextStyle(
                              fontSize:   16,
                              fontWeight: FontWeight.w700)),
                      Text(
                        CurrencyFormatter.format(cart.grandTotal),
                        style: const TextStyle(
                            fontSize:   18,
                            fontWeight: FontWeight.w700,
                            color:      AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ✅ Checkout button
                  SizedBox(
                    width:  double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: cart.isLoading
                          ? null
                          : () => _checkout(cart),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation:       0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: cart.isLoading
                          ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color:       Colors.white),
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Confirm Bill  •  ${CurrencyFormatter.format(cart.grandTotal)}',
                            style: const TextStyle(
                                fontSize:   15,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
      ]),
    );
  }
}

// ── Cart Item Tile ──────────────────────────────────────────────
class _CartItem extends StatelessWidget {
  final dynamic      item;
  final bool         isDark;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartItem({
    required this.item,
    required this.isDark,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:     const EdgeInsets.all(12),
      decoration:  BoxDecoration(
        color:        isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        // Product info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.productName,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(CurrencyFormatter.format(item.salePrice),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.primary)),
            ],
          ),
        ),
        // Qty controls
        Row(children: [
          _QtyBtn(icon: Icons.remove, onTap: onDecrement),
          Container(
            width:  36,
            alignment: Alignment.center,
            child: Text('${item.quantity}',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          _QtyBtn(icon: Icons.add, onTap: onIncrement),
        ]),
        const SizedBox(width: 8),
        // Total
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(CurrencyFormatter.format(item.total),
                style: const TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w600)),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline,
                  size: 16, color: AppColors.danger),
              padding:       EdgeInsets.zero,
              constraints:   const BoxConstraints(),
            ),
          ],
        ),
      ]),
    );
  }
}

// ── Qty Button ──────────────────────────────────────────────────
class _QtyBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width:  28,
      height: 28,
      decoration: BoxDecoration(
        color:        AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: AppColors.primary),
    ),
  );
}

// ── Payment Method Button ───────────────────────────────────────
class _PayBtn extends StatelessWidget {
  final String       label;
  final IconData     icon;
  final bool         selected;
  final VoidCallback onTap;
  const _PayBtn({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:  const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Icon(icon,
              size:  16,
              color: selected ? Colors.white : AppColors.primary),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  fontSize:   10,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.primary)),
        ]),
      ),
    ),
  );
}

// ── Summary Row ─────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _SummaryRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color:    color ?? Colors.grey.shade500)),
        Text(value,
            style: TextStyle(
                fontSize:   12,
                fontWeight: FontWeight.w500,
                color:      color ?? Colors.grey.shade700)),
      ],
    ),
  );
}

// ── Empty Cart ──────────────────────────────────────────────────
class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shopping_cart_outlined,
            size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text('Cart khali hai',
            style: TextStyle(
                fontSize: 16,
                color:    Colors.grey.shade400,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text('Products select karein',
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade400)),
      ],
    ),
  );
}