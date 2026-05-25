// lib/features/inventory/widgets/inventory_summary_card.dart
// StockPro — Inventory Summary Stats Card

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/premium_widgets.dart';


class InventorySummaryCard extends StatelessWidget {
  final InventorySummaryModel summary;
  const InventorySummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      gradient: AppColors.primaryGradient,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Inventory Value',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 13),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${summary.totalProducts} products',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(summary.totalValue),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MiniStat(
                label: 'In Stock',
                value: '${summary.inStockCount}',
                color: Colors.white,
              ),
              Container(
                  width: 1,
                  height: 28,
                  color: Colors.white.withOpacity(0.2),
                  margin: const EdgeInsets.symmetric(horizontal: 16)),
              _MiniStat(
                label: 'Low Stock',
                value: '${summary.lowStockCount}',
                color: const Color(0xFFFBBF24),
              ),
              Container(
                  width: 1,
                  height: 28,
                  color: Colors.white.withOpacity(0.2),
                  margin: const EdgeInsets.symmetric(horizontal: 16)),
              _MiniStat(
                label: 'Out of Stock',
                value: '${summary.outOfStockCount}',
                color: const Color(0xFFF87171),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.6), fontSize: 10)),
      ],
    );
  }
}