// lib/features/sales/sales_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/sale_provider.dart';
import '../../models/sale_model.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/confirm_dialog.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sales  = context.watch<SaleProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        title: const Text('Sales History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        elevation: 0,
      ),
      body: sales.isLoading
          ? const InlineLoader()
          : sales.sales.isEmpty
              ? const EmptyState.sales()
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: sales.sales.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final sale = sales.sales[i];
                    return _SaleTile(sale: sale);
                  },
                ),
    );
  }
}

class _SaleTile extends StatelessWidget {
  final SaleModel sale;
  const _SaleTile({required this.sale});

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final isRefund = sale.status == SaleStatus.refunded;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: (isRefund ? AppColors.danger : AppColors.primary)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isRefund
                ? Icons.assignment_return_outlined
                : Icons.receipt_long_outlined,
            size: 20,
            color: isRefund ? AppColors.danger : AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sale.billNumber,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(
              '${sale.customerName ?? 'Walk-in'}  •  ${sale.totalItems} items  •  ${DateFormatter.dateTime(sale.createdAt)}',
              style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.darkText3 : AppColors.lightText3),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        )),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(CurrencyFormatter.format(sale.total),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isRefund ? AppColors.danger : AppColors.success)),
            Text(sale.paymentMethod.label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.lightText3)),
            if (!isRefund)
              GestureDetector(
                onTap: () async {
                  final ok = await ConfirmDialog.show(
                    context,
                    title:   'Refund Sale',
                    message: 'Refund ${sale.billNumber}? Stock will be restored.',
                    confirmLabel: 'Refund',
                  );
                  if (ok && context.mounted) {
                    context.read<SaleProvider>().refundSale(sale.id);
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text('Refund',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.danger)),
                ),
              ),
          ],
        ),
      ]),
    );
  }
}
