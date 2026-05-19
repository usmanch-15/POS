// lib/features/inventory/inventory_screen.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Inventory / Stock Screen
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/empty_state.dart';
import 'stock_adjustment_screen.dart';
import 'widgets/stock_level_bar.dart';
import 'widgets/inventory_summary_card.dart';
import 'widgets/low_stock_list.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final inventory  = context.watch<InventoryProvider>();
    final products   = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        title: const Text('Stock',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: inventory.loadSummary,
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Summary Cards ──────────────────────────
            if (inventory.summary != null)
              InventorySummaryCard(summary: inventory.summary!),
            const SizedBox(height: 16),

            // ── Low Stock Alert ────────────────────────
            if (inventory.lowStock.isNotEmpty) ...[
              Row(children: [
                const Text('Low Stock',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text('${inventory.lowStock.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 8),
              LowStockList(products: inventory.lowStock),
              const SizedBox(height: 16),
            ],

            // ── All products with stock bar ────────────
            const Text('All Products',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (products.isLoading)
              const InlineLoader()
            else if (products.allProducts.isEmpty)
              const EmptyState.products()
            else
              ...products.allProducts.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: Text(p.name,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      StockAdjustmentScreen(product: p),
                                ),
                              ),
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(60, 28)),
                              child: const Text('Adjust',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary)),
                            ),
                          ]),
                          const SizedBox(height: 6),
                          StockLevelBar(product: p),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${p.quantity} units',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppColors.darkText3
                                          : AppColors.lightText3)),
                              Text(
                                CurrencyFormatter.format(
                                    p.inventoryValue),
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
