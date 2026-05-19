// lib/widgets/status_badge.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Colored Status / Label Badge
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum BadgeStatus { inStock, lowStock, outOfStock, success, warning, danger, info, primary }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeStatus status;
  final bool dot;

  const StatusBadge({
    super.key,
    required this.label,
    required this.status,
    this.dot = false,
  });

  // ── Stock presets ──────────────────────────────────────────
  factory StatusBadge.fromStockStatus(String stockStatus) {
    switch (stockStatus) {
      case 'out_of_stock':
        return const StatusBadge(label: 'Out of Stock', status: BadgeStatus.outOfStock, dot: true);
      case 'low_stock':
        return const StatusBadge(label: 'Low Stock', status: BadgeStatus.lowStock, dot: true);
      default:
        return const StatusBadge(label: 'In Stock', status: BadgeStatus.inStock, dot: true);
    }
  }

  Color get _bgColor {
    switch (status) {
      case BadgeStatus.inStock:    return AppColors.successLight;
      case BadgeStatus.lowStock:   return AppColors.warningLight;
      case BadgeStatus.outOfStock: return AppColors.dangerLight;
      case BadgeStatus.success:    return AppColors.successLight;
      case BadgeStatus.warning:    return AppColors.warningLight;
      case BadgeStatus.danger:     return AppColors.dangerLight;
      case BadgeStatus.info:       return AppColors.infoLight;
      case BadgeStatus.primary:    return AppColors.primary.withOpacity(0.12);
    }
  }

  Color get _textColor {
    switch (status) {
      case BadgeStatus.inStock:    return AppColors.success;
      case BadgeStatus.lowStock:   return AppColors.warning;
      case BadgeStatus.outOfStock: return AppColors.danger;
      case BadgeStatus.success:    return AppColors.success;
      case BadgeStatus.warning:    return AppColors.warning;
      case BadgeStatus.danger:     return AppColors.danger;
      case BadgeStatus.info:       return AppColors.info;
      case BadgeStatus.primary:    return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(color: _textColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }
}
