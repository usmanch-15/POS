// lib/features/dashboard/widgets/quick_actions_grid.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actions = [
      _Action('New Bill',    Icons.point_of_sale_rounded, AppColors.primary),
      _Action('Add Product', Icons.add_box_outlined,      AppColors.success),
      _Action('Stock In',    Icons.upload_rounded,        AppColors.warning),
      _Action('Reports',     Icons.bar_chart_rounded,     AppColors.info),
    ];

    return Row(
      children: actions.map((a) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: a.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(a.icon, color: a.color, size: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(a.label,
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      )).toList(),
    );
  }
}

class _Action {
  final String   label;
  final IconData icon;
  final Color    color;
  const _Action(this.label, this.icon, this.color);
}
