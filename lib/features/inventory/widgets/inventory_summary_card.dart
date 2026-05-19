// lib/features/inventory/widgets/inventory_summary_card.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/stock_model.dart';

class InventorySummaryCard extends StatelessWidget {
  final StockSummary summary;
  const InventorySummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Inventory Value',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            Text(CurrencyFormatter.format(summary.totalValue),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 14),
        Row(children: [
          _statItem('Total',    '${summary.totalProducts}', Colors.white),
          _statItem('In Stock', '${summary.inStockCount}',  AppColors.successLight),
          _statItem('Low',      '${summary.lowStockCount}', AppColors.warningLight),
          _statItem('Out',      '${summary.outOfStockCount}', AppColors.dangerLight),
        ]),
      ]),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Expanded(
      child: Column(children: [
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        Text(label,
            style: const TextStyle(
                color: Colors.white60, fontSize: 10)),
      ]),
    );
  }
}
