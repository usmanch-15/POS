// lib/features/dashboard/widgets/sales_chart_widget.dart
// StockPro — Weekly Sales Line Chart (fl_chart)

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';

class SalesChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data; // [{day, amount}]
  const SalesChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (data.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('No chart data')),
      );
    }

    final spots = data.asMap().entries.map((e) =>
        FlSpot(e.key.toDouble(),
            (e.value['amount'] as num).toDouble())).toList();

    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
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
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
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
                            : AppColors.lightText3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
                reservedSize: 28,
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((s) =>
                  LineTooltipItem(
                    'Rs. ${s.y.toStringAsFixed(0)}',
                    const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  )).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.primary,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 3.5,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: isDark
                      ? AppColors.darkCard
                      : AppColors.lightCard,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.18),
                    AppColors.primary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}