// lib/features/dashboard/widgets/quick_actions_grid.dart
// StockPro — Premium Quick Actions Grid

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  static const _actions = [
    _Action('New Bill',     Icons.point_of_sale_rounded,  AppColors.primary,   1),
    _Action('Add Product',  Icons.add_box_rounded,         AppColors.success,   2),
    _Action('Stock Update', Icons.inventory_rounded,       AppColors.warning,   3),
    _Action('Sales Report', Icons.bar_chart_rounded,       AppColors.info,      4),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.85,
      children: _actions.map((a) => _QuickActionTile(action: a)).toList(),
    );
  }
}

class _QuickActionTile extends StatefulWidget {
  final _Action action;
  const _QuickActionTile({required this.action});

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() async {
    await _ctrl.forward();
    await _ctrl.reverse();
    // Navigate based on action index
    if (!mounted) return;
    // Navigation handled by parent via callback — extend as needed
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final a      = widget.action;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: a.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(a.icon, color: a.color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                a.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText2 : AppColors.lightText2,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Action {
  final String label;
  final IconData icon;
  final Color color;
  final int index;
  const _Action(this.label, this.icon, this.color, this.index);
}