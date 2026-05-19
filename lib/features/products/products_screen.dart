// lib/features/products/products_screen.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Products Screen
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/product_provider.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_overlay.dart';
import 'add_product_screen.dart';
import 'widgets/product_card.dart';
import 'widgets/product_filter_bar.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        title: const Text('Products',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddProductScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search + filter ────────────────────────────
          Container(
            color: isDark ? AppColors.darkCard : Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: SearchBarWidget(
              hint:      'Search products...',
              onChanged: provider.search,
            ),
          ),
          ProductFilterBar(
            categories: provider.categories,
            selected:   provider.selectedCategory,
            onSelect:   provider.filterByCategory,
          ),

          // ── Stats bar ──────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? AppColors.darkCard : Colors.white,
            child: Row(children: [
              _statChip('Total: ${provider.totalProducts}',   AppColors.primary),
              const SizedBox(width: 8),
              _statChip('Low: ${provider.lowStockCount}',     AppColors.warning),
              const SizedBox(width: 8),
              _statChip('Out: ${provider.outOfStockCount}',   AppColors.danger),
            ]),
          ),
          const Divider(height: 1),

          // ── Product list ───────────────────────────────
          Expanded(
            child: provider.isLoading
                ? const InlineLoader()
                : provider.products.isEmpty
                    ? EmptyState.products(
                        onAction: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddProductScreen()),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: provider.products.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) =>
                            ProductCard(product: provider.products[i]),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddProductScreen())),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _statChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
