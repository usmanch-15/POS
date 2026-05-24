// lib/features/pos/widgets/payment_dialog.dart
// StockPro — Premium Payment Dialog

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../models/sale_model.dart';
import '../../../providers/cart_provider.dart';
import 'receipt_dialog.dart';

class PaymentDialog extends StatefulWidget {
  final String? cashierId;
  final String? cashierName;
  const PaymentDialog({super.key, this.cashierId, this.cashierName});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  PaymentMethod _method       = PaymentMethod.cash;
  final _cashCtrl             = TextEditingController();
  double        _cashReceived = 0;
  bool          _processing   = false;

  @override
  void dispose() {
    _cashCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    setState(() => _processing = true);
    final cart = context.read<CartProvider>();
    final sale = await cart.checkout(
      paymentMethod: _method,
      cashReceived: _cashReceived,
      cashierId: widget.cashierId,
      cashierName: widget.cashierName,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    if (sale != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ReceiptDialog(sale: sale),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final cart    = context.watch<CartProvider>();
    final change  = _method == PaymentMethod.cash
        ? cart.changeFor(_cashReceived)
        : 0.0;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Total amount display
                  PremiumCard(
                    gradient: AppColors.primaryGradient,
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      Text('Total Amount',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13)),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(cart.grandTotal),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${cart.itemCount} items',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12)),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // Payment method
                  const Text('Payment Method',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: PaymentMethod.values.map((m) {
                      final selected = _method == m;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _method = m),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              decoration: BoxDecoration(
                                gradient: selected
                                    ? AppColors.primaryGradient
                                    : null,
                                color: selected
                                    ? null
                                    : (isDark
                                    ? AppColors.darkSurface
                                    : AppColors.lightSurface),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? Colors.transparent
                                      : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder),
                                ),
                              ),
                              child: Column(children: [
                                Icon(
                                  _methodIcon(m),
                                  size: 22,
                                  color: selected
                                      ? Colors.white
                                      : (isDark
                                      ? AppColors.darkText2
                                      : AppColors.lightText2),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _methodLabel(m),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : (isDark
                                        ? AppColors.darkText2
                                        : AppColors.lightText2),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Cash fields
                  if (_method == PaymentMethod.cash) ...[
                    const SizedBox(height: 20),
                    AppTextField(
                      label: 'Cash Received',
                      hint: '0.00',
                      controller: _cashCtrl,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'))
                      ],
                      prefixIcon: const Icon(Icons.payments_rounded,
                          size: 18),
                      onChanged: (v) => setState(
                              () => _cashReceived = double.tryParse(v) ?? 0),
                    ),
                    if (_cashReceived >= cart.grandTotal) ...[
                      const SizedBox(height: 12),
                      PremiumCard(
                        color: AppColors.successLight,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Change',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success)),
                            Text(
                              CurrencyFormatter.format(change),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],

                  const SizedBox(height: 24),
                  GradientButton(
                    label: 'Complete Payment',
                    icon: Icons.check_circle_rounded,
                    loading: _processing,
                    onPressed: (_method == PaymentMethod.cash &&
                        _cashReceived < cart.grandTotal)
                        ? null
                        : _pay,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _methodIcon(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.cash:
        return Icons.payments_rounded;
      case PaymentMethod.card:
        return Icons.credit_card_rounded;
      case PaymentMethod.upi:
        return Icons.qr_code_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  String _methodLabel(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.upi:
        return 'UPI';
      default:
        return m.name;
    }
  }
}