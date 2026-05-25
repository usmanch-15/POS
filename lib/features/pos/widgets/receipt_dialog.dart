// lib/features/pos/widgets/receipt_dialog.dart
// StockPro — Premium Receipt / Bill Dialog

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../models/sale_model.dart';

class ReceiptDialog extends StatelessWidget {
  final SaleModel sale;
  const ReceiptDialog({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
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
              margin: const EdgeInsets.only(top: 12, bottom: 4),
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
                  // Success header
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_rounded,
                          color: AppColors.success, size: 32),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Center(
                    child: Text('Payment Successful!',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      DateFormatter.dateTime(sale.createdAt),
                      style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkText3
                              : AppColors.lightText3),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Receipt card
                  PremiumCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      // Bill info
                      InfoRow(
                          label: 'Bill No.',
                          value: sale.billNumber),
                      const Divider(height: 16),
                      InfoRow(
                          label: 'Cashier',
                          value: sale.cashierName ?? 'Admin'),
                      InfoRow(
                          label: 'Customer',
                          value: sale.customerName ?? 'Walk-in'),
                      InfoRow(
                          label: 'Payment',
                          value: sale.paymentMethod.name.toUpperCase()),
                      const Divider(height: 16),

                      // Items
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Items',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 8),
                      ...sale.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(children: [
                          Expanded(
                            child: Text(item.productName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.darkText2
                                      : AppColors.lightText2,
                                )),
                          ),
                          Text(
                            '${item.quantity} x ${CurrencyFormatter.format(item.salePrice)}',
                            style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkText3
                                    : AppColors.lightText3),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            CurrencyFormatter.format(item.total),
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ]),
                      )),

                      const Divider(height: 16),
                      if (sale.discount > 0)
                        InfoRow(
                          label: 'Discount',
                          value: '- ${CurrencyFormatter.format(sale.discount)}',
                          valueColor: AppColors.danger,
                        ),
                      if (sale.taxAmount > 0)
                        InfoRow(
                            label: 'Tax',
                            value: CurrencyFormatter.format(sale.taxAmount)),
                      const Divider(height: 16),
                      InfoRow(
                        label: 'Total',
                        value: CurrencyFormatter.format(sale.total),
                        valueColor: AppColors.success,
                        bold: true,
                      ),
                      if (sale.cashReceived != null &&
                          sale.cashReceived! > 0) ...[
                        InfoRow(
                            label: 'Cash Received',
                            value: CurrencyFormatter.format(
                                sale.cashReceived!)),
                        InfoRow(
                          label: 'Change',
                          value: CurrencyFormatter.format(
                              sale.cashReceived! - sale.total),
                          valueColor: AppColors.primary,
                          bold: true,
                        ),
                      ],
                    ]),
                  ),

                  const SizedBox(height: 20),

                  // Actions
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.print_rounded, size: 16),
                        label: const Text('Print'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        label: 'New Bill',
                        icon: Icons.add_rounded,
                        height: 46,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}