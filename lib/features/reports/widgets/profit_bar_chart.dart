// lib/features/reports/widgets/profit_bar_chart.dart
// StockPro — Profit Bar Chart using fl_chart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';

class ProfitBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const ProfitBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (data.isEmpty) {
      return const SizedBox(height: 160,
          child: Center(child: Text('No data')));
    }

    final maxY = data
        .map((d) => (d['profit'] as num?)?.toDouble() ?? 0)
        .reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.3,
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
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
                              : AppColors.lightText3),
                    ),
                  );
                },
                reservedSize: 26,
              ),
            ),
          ),
          barGroups: List.generate(data.length, (i) {
            final profit = (data[i]['profit'] as num?)?.toDouble() ?? 0;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: profit,
                  width: 18,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6)),
                  gradient: profit >= 0
                      ? AppColors.successGradient
                      : AppColors.dangerGradient,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ─── Category Pie Chart ───────────────────────────────────────────────────────
// lib/features/reports/widgets/category_pie_chart.dart

class CategoryPieChart extends StatefulWidget {
  final List<Map<String, dynamic>> data; // [{category, amount}]
  const CategoryPieChart({super.key, required this.data});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.data.isEmpty) {
      return const SizedBox(
          height: 200, child: Center(child: Text('No data')));
    }

    final total = widget.data
        .map((d) => (d['amount'] as num).toDouble())
        .reduce((a, b) => a + b);

    return Row(children: [
      Expanded(
        child: SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              pieTouchData: PieTouchData(
                touchCallback: (_, resp) {
                  setState(() {
                    _touched = resp?.touchedSection?.touchedSectionIndex ?? -1;
                  });
                },
              ),
              sections: List.generate(widget.data.length, (i) {
                final d       = widget.data[i];
                final amount  = (d['amount'] as num).toDouble();
                final pct     = (amount / total * 100).toStringAsFixed(1);
                final touched = i == _touched;
                final color   = AppColors.chartColors[
                i % AppColors.chartColors.length];

                return PieChartSectionData(
                  color: color,
                  value: amount,
                  title: touched ? '$pct%' : '',
                  radius: touched ? 72 : 60,
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                );
              }),
            ),
          ),
        ),
      ),
      const SizedBox(width: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
            widget.data.length > 5 ? 5 : widget.data.length, (i) {
          final d     = widget.data[i];
          final color = AppColors.chartColors[
          i % AppColors.chartColors.length];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 6),
              Text(
                d['category']?.toString() ?? '',
                style: TextStyle(
                    fontSize: 12,
                    color:
                    isDark ? AppColors.darkText2 : AppColors.lightText2),
              ),
            ]),
          );
        }),
      ),
    ]);
  }
}