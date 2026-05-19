// lib/widgets/empty_state.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Empty State Illustration Widget
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  // ── Presets ────────────────────────────────────────────────
  const EmptyState.products({super.key, this.onAction})
      : icon = Icons.inventory_2_outlined,
        title = 'No Products Yet',
        subtitle = 'Tap + to add your first product',
        actionLabel = 'Add Product';

  const EmptyState.sales({super.key, this.onAction})
      : icon = Icons.receipt_long_outlined,
        title = 'No Sales Today',
        subtitle = 'Start billing to see sales here',
        actionLabel = 'New Bill';

  const EmptyState.cart({super.key, this.onAction})
      : icon = Icons.shopping_cart_outlined,
        title = 'Cart is Empty',
        subtitle = 'Search or scan a product to add',
        actionLabel = null;

  const EmptyState.search({super.key, this.onAction})
      : icon = Icons.search_off_rounded,
        title = 'No Results Found',
        subtitle = 'Try a different search term',
        actionLabel = null;

  const EmptyState.reports({super.key, this.onAction})
      : icon = Icons.bar_chart_outlined,
        title = 'No Data Available',
        subtitle = 'No records found for this period',
        actionLabel = null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.lightText1,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkText3 : AppColors.lightText3,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
