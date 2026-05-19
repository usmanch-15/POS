// lib/features/pos/pos_screen.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — POS / Billing Screen
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
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
  String _searchQuery  = '';
  String _selectedCat  = 'All';
  bool   _showCart     = false; // mobile: toggle cart

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final cart     = context.watch<CartProvider>();
    final products = context.watch<ProductProvider>();
    final isTablet = !ResponsiveHelper.isMobile(context);

    final categories = products.categories;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        title: const Text('Billing',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        elevation: 0,
        actions: [
          // Mobile: cart toggle button with badge
          if (!isTablet)
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: Icon(
                    _showCart
                        ? Icons.grid_view_rounded
                        : Icons.shopping_cart_rounded,
                    color: AppColors.primary,
                  ),
                  onPressed: () => setState(() => _showCart = !_showCart),
                ),
                if (cart.itemCount > 0 && !_showCart)
                  Positioned(
                    right: 8, top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                      child: Text('${cart.itemCount}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: isTablet
          ? _TabletLayout(
              searchQuery:  _searchQuery,
              selectedCat:  _selectedCat,
              categories:   categories,
              onSearch:     (q) => setState(() => _searchQuery = q),
              onCatSelect:  (c) => setState(() => _selectedCat = c),
            )
          : _MobileLayout(
              showCart:     _showCart,
              searchQuery:  _searchQuery,
              selectedCat:  _selectedCat,
              categories:   categories,
              onSearch:     (q) => setState(() => _searchQuery = q),
              onCatSelect:  (c) => setState(() => _selectedCat = c),
            ),
    );
  }
}

// ── Tablet: side-by-side ──────────────────────────────────────
class _TabletLayout extends StatelessWidget {
  final String   searchQuery;
  final String   selectedCat;
  final List<String> categories;
  final void Function(String) onSearch;
  final void Function(String) onCatSelect;

  const _TabletLayout({
    required this.searchQuery,
    required this.selectedCat,
    required this.categories,
    required this.onSearch,
    required this.onCatSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Products (left)
        Expanded(
          flex: 3,
          child: Column(
            children: [
              BarcodeScannerBar(onSearch: onSearch),
              _CategoryBar(
                  categories: categories,
                  selected:   selectedCat,
                  onSelect:   onCatSelect),
              Expanded(
                child: ProductGrid(
                  searchQuery: searchQuery,
                  category:    selectedCat,
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Cart (right)
        const SizedBox(
          width: 320,
          child: CartPanel(),
        ),
      ],
    );
  }
}

// ── Mobile: toggle view ───────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  final bool     showCart;
  final String   searchQuery;
  final String   selectedCat;
  final List<String> categories;
  final void Function(String) onSearch;
  final void Function(String) onCatSelect;

  const _MobileLayout({
    required this.showCart,
    required this.searchQuery,
    required this.selectedCat,
    required this.categories,
    required this.onSearch,
    required this.onCatSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (showCart) return const CartPanel();

    return Column(
      children: [
        BarcodeScannerBar(onSearch: onSearch),
        _CategoryBar(
            categories: categories,
            selected:   selectedCat,
            onSelect:   onCatSelect),
        Expanded(
          child: ProductGrid(
            searchQuery: searchQuery,
            category:    selectedCat,
          ),
        ),
      ],
    );
  }
}

// ── Category filter bar ───────────────────────────────────────
class _CategoryBar extends StatelessWidget {
  final List<String>       categories;
  final String             selected;
  final void Function(String) onSelect;

  const _CategoryBar({
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
                    : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
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
                            : (isDark ? AppColors.darkText2 : AppColors.lightText2))),
              ),
            ),
          );
        },
      ),
    );
  }
}
