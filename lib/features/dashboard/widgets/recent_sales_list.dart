// lib/features/dashboard/widgets/recent_sales_list.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/sale_model.dart';
import '../../../widgets/empty_state.dart';

class RecentSalesList extends StatelessWidget {
  final List<SaleModel> sales;
  const RecentSalesList({super.key, required this.sales});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (sales.isEmpty) return const EmptyState.sales();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sales.length.clamp(0, 8),
        separatorBuilder: (_, __) => Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        itemBuilder: (_, i) {
          final sale = sales[i];
          return ListTile(
            dense: true,
            leading: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.receipt_outlined,
                  size: 18, color: AppColors.primary),
            ),
            title: Text(sale.billNumber,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text(
              '${sale.customerName ?? 'Walk-in'} • ${DateFormatter.time(sale.createdAt)}',
              style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.darkText3 : AppColors.lightText3),
            ),
            trailing: Text(
              CurrencyFormatter.format(sale.total),
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success),
            ),
          );
        },
      ),
    );
  }
}
