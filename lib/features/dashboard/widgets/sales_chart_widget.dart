// lib/features/dashboard/widgets/sales_chart_widget.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/report_model.dart';

class SalesChartWidget extends StatelessWidget {
  final List<ChartDataPoint> dataPoints;
  const SalesChartWidget({super.key, required this.dataPoints});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (dataPoints.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: const Center(
          child: Text('No data yet',
              style: TextStyle(color: AppColors.lightText3)),
        ),
      );
    }

    final maxVal =
        dataPoints.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legend
          Row(children: [
            _legend('Sales', AppColors.primary),
            const SizedBox(width: 16),
            _legend('Profit', AppColors.success),
          ]),
          const SizedBox(height: 16),
          // Bars
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: dataPoints.map((dp) {
                final ratio = maxVal > 0 ? dp.value / maxVal : 0.0;
                final ratio2 = maxVal > 0 && dp.value2 != null
                    ? (dp.value2! / maxVal)
                    : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Bars
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _bar(ratio, AppColors.primary, 100),
                            const SizedBox(width: 2),
                            if (dp.value2 != null)
                              _bar(ratio2, AppColors.success, 100),
                          ],
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
        ],
      ),
    );
  }

  Widget _bar(double ratio, Color color, double maxH) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      width: 10,
      height: (ratio * maxH).clamp(4, maxH),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _legend(String label, Color color) {
    return Row(children: [
      Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 11)),
    ]);
  }
}
