import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/sale_model.dart';
import '../../../services/printer_service.dart';
import '../../../services/local_storage_service.dart';

class ReceiptDialog extends StatelessWidget {
  final SaleModel sale; // ✅ FIX: late hataya — final use karo
  const ReceiptDialog({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final biz    = LocalStorageService.businessName;
    final addr   = LocalStorageService.address;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize:     0.95,
      minChildSize:     0.5,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 16),

          // Success icon
          Container(
            width: 56, height: 56,
            decoration: const BoxDecoration(
              color: AppColors.successLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                color: AppColors.success, size: 32),
          ),
          const SizedBox(height: 8),
          const Text('Sale Complete!',
              style: TextStyle(
                  fontSize:   16,
                  fontWeight: FontWeight.w700,
                  color:      AppColors.success)),
          const SizedBox(height: 16),

          // Receipt body
          Expanded(
            child: SingleChildScrollView(
              controller: ctrl,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: [
                // Business info
                Text(biz,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                if (addr.isNotEmpty)
                  Text(addr,
                      style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkText3
                              : AppColors.lightText3)),
                const SizedBox(height: 4),
                Text(
                  'Bill: ${sale.billNumber}  •  ${DateFormatter.dateTime(sale.createdAt)}',
                  style: const TextStyle(fontSize: 11),
                ),
                const Divider(height: 20),

                // Items
                ...sale.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(children: [
                    Expanded(
                      child: Text(
                        '${item.productName} x${item.quantity}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(CurrencyFormatter.format(item.total),
                        style: const TextStyle(
                            fontSize:   13,
                            fontWeight: FontWeight.w600)),
                  ]),
                )),

                const Divider(height: 20),
                _row('Subtotal', CurrencyFormatter.format(sale.subtotal)),
                if (sale.discountAmount > 0)
                  _row('Discount',
                      '- ${CurrencyFormatter.format(sale.discountAmount)}',
                      color: AppColors.danger),
                if (sale.taxAmount > 0)
                  _row('Tax', CurrencyFormatter.format(sale.taxAmount)),
                const Divider(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    Text(CurrencyFormatter.format(sale.total),
                        style: const TextStyle(
                            fontSize:   16,
                            fontWeight: FontWeight.w700,
                            color:      AppColors.primary)),
                  ],
                ),
                if (sale.paymentMethod == PaymentMethod.cash &&
                    sale.changeGiven > 0) ...[
                  const SizedBox(height: 8),
                  _row('Cash Received',
                      CurrencyFormatter.format(sale.cashReceived)),
                  _row('Change',
                      CurrencyFormatter.format(sale.changeGiven),
                      color: AppColors.success),
                ],
                const SizedBox(height: 12),
                Text(LocalStorageService.receiptNote,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkText3
                            : AppColors.lightText3)),
                const SizedBox(height: 24),
              ]),
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  // ✅ FIX: (sale as BuildContext) → (context, sale)
                  onPressed: () =>
                      PrinterService.printReceipt(context, sale),
                  icon:  const Icon(Icons.print_outlined, size: 18),
                  label: const Text('Print'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape:   RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape:   RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('New Bill',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _row(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(value,
              style: TextStyle(
                  fontSize:   12,
                  fontWeight: FontWeight.w600,
                  color:      color)),
        ],
      ),
    );
  }
}