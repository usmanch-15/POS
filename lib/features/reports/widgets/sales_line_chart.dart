// lib/features/reports/widgets/sales_line_chart.dart
// StockPro — Sales Line Chart (same style as dashboard chart)

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';

class SalesLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const SalesLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (data.isEmpty) {
      return const SizedBox(
          height: 180, child: Center(child: Text('No data')));
    }

    final spots = data.asMap().entries
        .map((e) => FlSpot(
        e.key.toDouble(), (e.value['amount'] as num).toDouble()))
        .toList();

    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 180,
      child: LineChart(LineChartData(
        minY: 0,
        maxY: maxY * 1.2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (_) => FlLine(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.05),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= data.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    data[i]['day']?.toString() ?? '',
                    style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.darkText3
                            : AppColors.lightText3),
                  ),
                );
              },
              reservedSize: 28,
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.success,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 3.5,
                color: AppColors.success,
                strokeWidth: 2,
                strokeColor:
                isDark ? AppColors.darkCard : AppColors.lightCard,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.success.withOpacity(0.15),
                  AppColors.success.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}