// lib/features/pos/widgets/product_grid.dart
// StockPro — POS Product Grid

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../providers/product_provider.dart';
import 'product_tile.dart';

class ProductGrid extends StatelessWidget {
  final String searchQuery;
  final String selectedCategory;
  const ProductGrid({
    super.key,
    required this.searchQuery,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<ProductProvider>();
    final isMobile  = ResponsiveHelper.isMobile(context);
    final crossAxis = isMobile ? 2 : 3;

    var products = provider.allProducts;

    if (selectedCategory != 'All') {
      products = products
          .where((p) => p.category == selectedCategory)
          .toList();
    }

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      products = products
          .where((p) =>
      p.name.toLowerCase().contains(q) ||
          p.barcode?.contains(q) == true)
          .toList();
    }

    if (provider.isLoading) return const PremiumLoader();

    if (products.isEmpty) {
      return searchQuery.isNotEmpty
          ? const PremiumEmptyState.search()
          : const PremiumEmptyState.products();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxis,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => ProductTile(product: products[i]),
    );
  }
}