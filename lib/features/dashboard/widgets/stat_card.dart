// lib/features/dashboard/widgets/stat_card.dart
// StockPro — Premium Stat Card with gradient + glow

import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';

class StatCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final LinearGradient gradient;
  final String? sub;
  final bool isCurrency;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    this.sub,
    this.isCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
            ],
          ),
          const Spacer(),
          Text(
            isCurrency
                ? CurrencyFormatter.format(value)
                : value.toInt().toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(sub!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                )),
          ],
        ],
      ),
    );
  }
}