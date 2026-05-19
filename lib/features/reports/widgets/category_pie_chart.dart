// lib/features/reports/widgets/category_pie_chart.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/report_model.dart';

class CategoryPieChart extends StatelessWidget {
  final List<CategorySales> data;
  const CategoryPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('No data')),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        children: data.asMap().entries.map((e) {
          final i    = e.key;
          final cat  = e.value;
          final color = AppColors.categoryColors[i % AppColors.categoryColors.length];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(cat.category,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                        Text(
                          '${cat.percentage.toStringAsFixed(1)}%  •  ${CurrencyFormatter.formatCompact(cat.totalSales)}',
                          style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkText3
                                  : AppColors.lightText3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: cat.percentage / 100,
                        minHeight: 5,
                        backgroundColor: color.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          );
        }).toList(),
      ),
    );
  }
}
