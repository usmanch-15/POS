// lib/features/products/products_screen.dart
// StockPro — Premium Products Screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../providers/product_provider.dart';
import 'add_product_screen.dart';
import 'widgets/product_card.dart';
import 'widgets/product_filter_bar.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final provider  = context.watch<ProductProvider>();
    final isTablet  = !ResponsiveHelper.isMobile(context);
    final columns   = ResponsiveHelper.gridColumns(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddProductScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: const EdgeInsets.only(right: 4, top: 10, bottom: 10),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('Add',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search + filter
          Container(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: TextField(
              onChanged: provider.search,
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search_rounded,
                    size: 20, color: AppColors.primary),
              ),
            ),
          ),

          // Category filter
          ProductFilterBar(
            categories: provider.categories,
            selected: provider.selectedCategory,
            onSelect: provider.filterByCategory,
          ),

          // Stats row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            child: Row(children: [
              _StatChip(
                  '${provider.totalProducts} Total', AppColors.primary),
              const SizedBox(width: 8),
              _StatChip(
                  '${provider.lowStockCount} Low', AppColors.warning),
              const SizedBox(width: 8),
              _StatChip(
                  '${provider.outOfStockCount} Out', AppColors.danger),
            ]),
          ),
          Divider(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder),

          // Product list/grid
          Expanded(
            child: provider.isLoading
                ? const PremiumLoader()
                : provider.products.isEmpty
                ? PremiumEmptyState.products(
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddProductScreen()),
              ),
            )
                : isTablet
                ? _ProductGrid(
              products: provider.products,
              columns: columns,
            )
                : _ProductList(products: provider.products),
          ),
        ],
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final List products;
  final int columns;
  const _ProductGrid({required this.products, required this.columns});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => ProductCard(product: products[i]),
    );
  }
}

class _ProductList extends StatelessWidget {
  final List products;
  const _ProductList({required this.products});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => ProductCard(product: products[i]),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }
}