// lib/features/reports/widgets/report_card.dart
import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';

class ReportCard extends StatelessWidget {
  final String         label;
  final double         value;
  final LinearGradient gradient;
  final bool           isCurrency;

  const ReportCard({
    super.key,
    required this.label,
    required this.value,
    required this.gradient,
    this.isCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 11)),
          Text(
            isCurrency
                ? CurrencyFormatter.formatCompact(value)
                : value.toInt().toString(),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
