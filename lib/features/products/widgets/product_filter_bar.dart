// lib/features/products/widgets/product_filter_bar.dart
// StockPro — Category Filter Chips Bar

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProductFilterBar extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  const ProductFilterBar({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: ['All', ...categories].map((cat) {
          final isSelected = selected == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  color: isSelected
                      ? null
                      : (isDark ? AppColors.darkSurface : AppColors.lightElevated),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.darkText2 : AppColors.lightText2),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}