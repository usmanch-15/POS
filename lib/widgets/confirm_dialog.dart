// lib/widgets/confirm_dialog.dart
// StockPro — Premium Confirm Dialog

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final bool isDanger;
  final VoidCallback onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final btnColor = isDanger ? AppColors.danger : AppColors.primary;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: btnColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isDanger ? Icons.warning_amber_rounded : Icons.help_outline_rounded,
            color: btnColor, size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ]),
      content: Text(message,
          style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkText2 : AppColors.lightText2,
              height: 1.5)),
      actionsPadding:
      const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: btnColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}