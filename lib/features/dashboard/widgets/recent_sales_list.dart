// lib/features/dashboard/widgets/recent_sales_list.dart
// StockPro — Premium Recent Sales List

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../models/sale_model.dart';

class RecentSalesList extends StatelessWidget {
  final List<SaleModel> sales;
  const RecentSalesList({super.key, required this.sales});

  @override
  Widget build(BuildContext context) {
    if (sales.isEmpty) return const PremiumEmptyState.sales();

    return Column(
      children: sales.take(5).map((s) => _SaleRow(sale: s)).toList(),
    );
  }
}

class _SaleRow extends StatelessWidget {
  final SaleModel sale;
  const _SaleRow({required this.sale});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_outlined,
                color: AppColors.primary, size: 17),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sale.billNumber,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkText1 : AppColors.lightText1,
                    )),
                const SizedBox(height: 2),
                Text(DateFormatter.relative(sale.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkText3 : AppColors.lightText3,
                    )),
              ],
            ),
          ),

          // Amount
          Text(
            CurrencyFormatter.format(sale.total),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}