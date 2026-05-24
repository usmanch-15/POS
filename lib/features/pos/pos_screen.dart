// lib/features/pos/pos_screen.dart
// StockPro — Premium POS / Billing Screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import 'widgets/product_grid.dart';
import 'widgets/cart_panel.dart';
import 'widgets/barcode_scanner_bar.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});
  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  String _searchQuery = '';
  String _selectedCat = 'All';
  bool   _showCart    = false;

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final cart      = context.watch<CartProvider>();
    final products  = context.watch<ProductProvider>();
    final isTablet  = !ResponsiveHelper.isMobile(context);
    final categories = products.categories;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        title: const Text('Billing'),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        actions: [
          if (!isTablet)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _showCart
                          ? AppColors.primary.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _showCart
                            ? Icons.grid_view_rounded
                            : Icons.shopping_cart_rounded,
                        color: AppColors.primary,
                      ),
                      onPressed: () =>
                          setState(() => _showCart = !_showCart),
                    ),
                  ),
                  if (cart.itemCount > 0 && !_showCart)
                    Positioned(
                      right: 6, top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
      body: isTablet
          ? _TabletLayout(
        searchQuery: _searchQuery,
        selectedCat: _selectedCat,
        categories: categories,
        onSearch: (v) => setState(() => _searchQuery = v),
        onCatSelect: (v) => setState(() => _selectedCat = v),
      )
          : _showCart
          ? CartPanel(onBack: () => setState(() => _showCart = false))
          : _MobileProductView(
        searchQuery: _searchQuery,
        selectedCat: _selectedCat,
        categories: categories,
        onSearch: (v) => setState(() => _searchQuery = v),
        onCatSelect: (v) => setState(() => _selectedCat = v),
      ),
    );
  }
}

// ─── Tablet Layout ───────────────────────────────────────────
class _TabletLayout extends StatelessWidget {
  final String searchQuery;
  final String selectedCat;
  final List<String> categories;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onCatSelect;

  const _TabletLayout({
    required this.searchQuery,
    required this.selectedCat,
    required this.categories,
    required this.onSearch,
    required this.onCatSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Column(
            children: [
              _SearchAndFilter(
                searchQuery: searchQuery,
                selectedCat: selectedCat,
                categories: categories,
                onSearch: onSearch,
                onCatSelect: onCatSelect,
              ),
              Expanded(
                child: ProductGrid(
                  searchQuery: searchQuery,
                  // FIX: removed wrong `selectedCategory:` param and hardcoded `category: ''`
                  // Now correctly passes the selected category
                  category: selectedCat,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        const SizedBox(
          width: 340,
          child: CartPanel(),
        ),
      ],
    );
  }
}

// ─── Mobile Product View ─────────────────────────────────────
class _MobileProductView extends StatelessWidget {
  final String searchQuery;
  final String selectedCat;
  final List<String> categories;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onCatSelect;

  const _MobileProductView({
    required this.searchQuery,
    required this.selectedCat,
    required this.categories,
    required this.onSearch,
    required this.onCatSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SearchAndFilter(
          searchQuery: searchQuery,
          selectedCat: selectedCat,
          categories: categories,
          onSearch: onSearch,
          onCatSelect: onCatSelect,
        ),
        Expanded(
          child: ProductGrid(
            searchQuery: searchQuery,
            // FIX: removed wrong `selectedCategory:`, replaced with correct `category:`
            category: selectedCat,
          ),
        ),
      ],
    );
  }
}

// ─── Search + Filter Bar ─────────────────────────────────────
class _SearchAndFilter extends StatelessWidget {
  final String searchQuery;
  final String selectedCat;
  final List<String> categories;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onCatSelect;

  const _SearchAndFilter({
    required this.searchQuery,
    required this.selectedCat,
    required this.categories,
    required this.onSearch,
    required this.onCatSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: TextField(
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search_rounded,
                    size: 20, color: AppColors.primary),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
          ),
          // FIX: pass `onSearch` to BarcodeScannerBar — it requires this param
          BarcodeScannerBar(onSearch: onSearch),
          // Category chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                'All',
                ...categories,
              ].map((cat) {
                final selected = selectedCat == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onCatSelect(cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? AppColors.primaryGradient
                            : null,
                        color: selected
                            ? null
                            : (isDark
                            ? AppColors.darkSurface
                            : AppColors.lightElevated),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: selected
                              ? Colors.transparent
                              : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : (isDark
                              ? AppColors.darkText2
                              : AppColors.lightText2),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}