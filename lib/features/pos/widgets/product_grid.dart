// lib/features/pos/widgets/product_grid.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_overlay.dart';
import 'product_tile.dart';

class ProductGrid extends StatelessWidget {
  final String searchQuery;
  final String category;

  const ProductGrid({
    super.key,
    required this.searchQuery,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    if (productProvider.isLoading) return const InlineLoader();

    // Filter products
    var list = productProvider.allProducts
        .where((p) => p.isActive)
        .toList();

    if (category != 'All') {
      list = list.where((p) => p.category == category).toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((p) =>
          p.name.toLowerCase().contains(q) ||
          (p.barcode?.contains(q) ?? false)).toList();
    }

    if (list.isEmpty) return const EmptyState.products();

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:  2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.3,
      ),
      itemCount: list.length,
      itemBuilder: (_, i) => ProductTile(product: list[i]),
    );
  }
}
