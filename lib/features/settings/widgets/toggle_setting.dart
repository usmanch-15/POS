// lib/features/settings/widgets/toggle_setting.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ToggleSetting extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     value;
  final void Function(bool) onToggle;

  const ToggleSetting({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: ListTile(
        leading: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        title: Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: Switch.adaptive(
          value:           value,
          onChanged:       onToggle,
          activeColor:     AppColors.primary,
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
