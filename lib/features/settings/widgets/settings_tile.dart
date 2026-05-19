// lib/features/settings/widgets/settings_tile.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SettingsTile extends StatelessWidget {
  final IconData  icon;
  final String    label;
  final String?   sub;
  final VoidCallback? onTap;
  final Color?    iconColor;
  final Color?    labelColor;
  final Widget?   trailing;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.label,
    this.sub,
    this.onTap,
    this.iconColor,
    this.labelColor,
    this.trailing,
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
        onTap: onTap,
        leading: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              size: 20,
              color: iconColor ?? AppColors.primary),
        ),
        title: Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: labelColor)),
        subtitle: sub != null
            ? Text(sub!,
                style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkText3
                        : AppColors.lightText3))
            : null,
        trailing: trailing ??
            (onTap != null
                ? Icon(Icons.chevron_right_rounded,
                    color: isDark
                        ? AppColors.darkText3
                        : AppColors.lightText3)
                : null),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
