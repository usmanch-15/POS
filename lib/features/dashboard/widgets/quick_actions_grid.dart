import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../pos/pos_screen.dart';
import '../../products/add_product_screen.dart';
import '../../sales/sales_screen.dart';
import '../../inventory/inventory_screen.dart';
import '../../reports/reports_screen.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final actions = [
      _Action(
        label:    'New Sale',
        icon:     Icons.point_of_sale_rounded,
        gradient: AppColors.primaryGradient,
        onTap:    () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PosScreen())),
      ),
      _Action(
        label:    'Add Product',
        icon:     Icons.add_box_rounded,
        gradient: AppColors.successGradient,
        onTap:    () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddProductScreen())),
      ),
      _Action(
        label:    'Sales History',
        icon:     Icons.receipt_long_rounded,
        gradient: AppColors.warningGradient,
        onTap:    () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SalesScreen())),
      ),
      _Action(
        label:    'Inventory',
        icon:     Icons.inventory_2_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF7B2FBE), Color(0xFF9C4FD6)],
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
        ),
        onTap:    () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const InventoryScreen())),
      ),
      _Action(
        label:    'Reports',
        icon:     Icons.bar_chart_rounded,
        gradient: AppColors.dangerGradient,
        onTap:    () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ReportsScreen())),
      ),
    ];

    return GridView.builder(
      shrinkWrap:  true,
      physics:     const NeverScrollableScrollPhysics(),
      itemCount:   actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:   3,
        mainAxisSpacing:  10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (_, i) => _ActionTile(
        action: actions[i],
        isDark: isDark,
      ),
    );
  }
}

// ── Single action tile ──────────────────────────────────────────
class _ActionTile extends StatefulWidget {
  final _Action action;
  final bool    isDark;
  const _ActionTile({required this.action, required this.isDark});

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => _ctrl.forward(),
      onTapUp:     (_) { _ctrl.reverse(); widget.action.onTap(); },
      onTapCancel: ()  => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            gradient:     widget.action.gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color:      widget.action.gradient.colors.first
                    .withOpacity(0.30),
                blurRadius: 10,
                offset:     const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:        Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.action.icon,
                  color: Colors.white,
                  size:  24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.action.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color:      Colors.white,
                  fontSize:   11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Data class ──────────────────────────────────────────────────
class _Action {
  final String         label;
  final IconData       icon;
  final LinearGradient gradient;
  final VoidCallback   onTap;

  const _Action({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });
}