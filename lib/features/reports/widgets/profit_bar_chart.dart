// lib/features/reports/widgets/profit_bar_chart.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/report_model.dart';

class ProfitBarChart extends StatelessWidget {
  final List<ChartDataPoint> dataPoints;
  const ProfitBarChart({super.key, required this.dataPoints});

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
        Row(children: [
          _dot(AppColors.primary), const SizedBox(width: 4),
          const Text('Sales', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 12),
          _dot(AppColors.success), const SizedBox(width: 4),
          const Text('Profit', style: TextStyle(fontSize: 11)),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: dataPoints.map((dp) {
              final r1 = maxVal > 0 ? dp.value / maxVal : 0.0;
              final r2 = maxVal > 0 && dp.value2 != null
                  ? dp.value2! / maxVal : 0.0;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _bar(r1, AppColors.primary, 90),
                          const SizedBox(width: 2),
                          if (dp.value2 != null)
                            _bar(r2, AppColors.success, 90),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(dp.label,
                          style: TextStyle(
                              fontSize: 9,
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

  Widget _bar(double ratio, Color color, double maxH) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      width: 9,
      height: (ratio * maxH).clamp(4, maxH),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: 8, height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}
