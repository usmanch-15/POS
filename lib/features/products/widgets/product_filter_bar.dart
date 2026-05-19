// lib/features/products/widgets/product_filter_bar.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProductFilterBar extends StatelessWidget {
  final List<String>       categories;
  final String             selected;
  final void Function(String) onSelect;

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
      height: 44,
      color: isDark ? AppColors.darkCard : Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final cat      = categories[i];
          final isActive = cat == selected;
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Center(
                child: Text(cat,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isActive
                            ? Colors.white
                            : (isDark
                                ? AppColors.darkText2
                                : AppColors.lightText2))),
              ),
            ),
          );
        },
      ),
    );
  }
}
