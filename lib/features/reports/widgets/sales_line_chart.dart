// lib/features/reports/widgets/sales_line_chart.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/report_model.dart';

class SalesLineChart extends StatelessWidget {
  final List<ChartDataPoint> dataPoints;
  const SalesLineChart({super.key, required this.dataPoints});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (dataPoints.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('No data')),
      );
    }

    final maxVal = dataPoints.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(children: [
        SizedBox(
          height: 130,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: dataPoints.map((dp) {
              final ratio = maxVal > 0 ? dp.value / maxVal : 0.0;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Tooltip(
                        message: CurrencyFormatter.formatCompact(dp.value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          height: (ratio * 100).clamp(4, 100),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(dp.label,
                          style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.darkText3
                                  : AppColors.lightText3)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }
}
