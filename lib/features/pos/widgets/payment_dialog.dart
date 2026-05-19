// lib/features/pos/widgets/payment_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
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
  PaymentMethod _method        = PaymentMethod.cash;
  final _cashCtrl              = TextEditingController();
  double        _cashReceived  = 0;

  @override
  void dispose() {
    _cashCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final cart = context.read<CartProvider>();
    final sale = await cart.checkout(
      paymentMethod: _method,
      cashReceived:  _cashReceived,
      cashierId:     widget.cashierId,
      cashierName:   widget.cashierName,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart   = context.watch<CartProvider>();
    final change = _method == PaymentMethod.cash
        ? cart.changeFor(_cashReceived)
        : 0.0;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          controller: ctrl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Payment',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),

              // Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount',
                      style: TextStyle(fontSize: 14)),
                  Text(CurrencyFormatter.format(cart.grandTotal),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ],
              ),
              const Divider(height: 28),

              // Payment method
              const Text('Payment Method',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(children: [
                _MethodBtn(
                    label: 'Cash',
                    icon: Icons.payments_outlined,
                    active: _method == PaymentMethod.cash,
                    onTap: () =>
                        setState(() => _method = PaymentMethod.cash)),
                const SizedBox(width: 10),
                _MethodBtn(
                    label: 'Card',
                    icon: Icons.credit_card_rounded,
                    active: _method == PaymentMethod.card,
                    onTap: () =>
                        setState(() => _method = PaymentMethod.card)),
              ]),

              // Cash received field
              if (_method == PaymentMethod.cash) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _cashCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*'))
                  ],
                  onChanged: (v) =>
                      setState(() => _cashReceived = double.tryParse(v) ?? 0),
                  decoration: InputDecoration(
                    labelText: 'Cash Received',
                    prefixText: '${CurrencyFormatter.symbol} ',
                  ),
                ),
                if (_cashReceived >= cart.grandTotal) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Change',
                            style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600)),
                        Text(CurrencyFormatter.format(change),
                            style: const TextStyle(
                                color: AppColors.success,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 28),

              // Confirm button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: cart.isLoading ? null : _pay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: cart.isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Text('Confirm Payment',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodBtn extends StatelessWidget {
  final String   label;
  final IconData icon;
  final bool     active;
  final VoidCallback onTap;

  const _MethodBtn({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: active ? Colors.white : AppColors.primary),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}
