// lib/widgets/search_bar_widget.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Reusable Search Bar Widget
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';

class SearchBarWidget extends StatefulWidget {
  final String hint;
  final void Function(String) onChanged;
  final void Function()? onClear;
  final TextEditingController? controller;
  final bool autofocus;

  const SearchBarWidget({
    super.key,
    this.hint = 'Search...',
    required this.onChanged,
    this.onClear,
    this.controller,
    this.autofocus = false,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _ctrl;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller ?? TextEditingController();
    _ctrl.addListener(() {
      setState(() => _hasText = _ctrl.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) _ctrl.dispose();
    super.dispose();
  }

  void _clear() {
    _ctrl.clear();
    widget.onChanged('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            Icons.search_rounded,
            size: 20,
            color: isDark ? AppColors.darkText3 : AppColors.lightText3,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _ctrl,
              autofocus: widget.autofocus,
              onChanged: widget.onChanged,
              style: TextStyle(
                fontSize: AppDimensions.fontBase,
                color: isDark ? Colors.white : AppColors.lightText1,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: AppDimensions.fontBase,
                  color: isDark ? AppColors.darkText3 : AppColors.lightText3,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_hasText)
            GestureDetector(
              onTap: _clear,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: isDark ? AppColors.darkText3 : AppColors.lightText3,
                ),
              ),
            )
          else
            const SizedBox(width: 14),
        ],
      ),
    );
  }
}
