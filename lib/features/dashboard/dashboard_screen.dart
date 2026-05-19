// lib/features/dashboard/dashboard_screen.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Dashboard Screen
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/sale_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/auth_provider.dart';
import 'widgets/stat_card.dart';
import 'widgets/recent_sales_list.dart';
import 'widgets/low_stock_alert.dart';
import 'widgets/sales_chart_widget.dart';
import 'widgets/quick_actions_grid.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final sale      = context.watch<SaleProvider>();
    final product   = context.watch<ProductProvider>();
    final report    = context.watch<ReportProvider>();
    final auth      = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      body: RefreshIndicator(
        onRefresh: () => report.loadDashboardData(),
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // ── Header ────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 20, right: 20, bottom: 24,
                ),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_greeting(),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(auth.userName.isNotEmpty ? auth.userName : 'StockPro',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4)),
                      ]),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.storefront_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: Colors.white60, size: 13),
                      const SizedBox(width: 6),
                      Text(DateFormatter.dateLong(DateTime.now()),
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 12)),
                    ]),
                  ],
                ),
              ),
            ),

            // ── Stat Cards ────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverGrid(
                delegate: SliverChildListDelegate([
                  StatCard(
                    label:    "Today's Sales",
                    value:    sale.todayRevenue,
                    icon:     Icons.receipt_long_rounded,
                    gradient: AppColors.primaryGradient,
                    sub:      '${sale.todayBillCount} bills',
                  ),
                  StatCard(
                    label:    "Today's Profit",
                    value:    sale.todayProfit,
                    icon:     Icons.trending_up_rounded,
                    gradient: AppColors.successGradient,
                    sub:      'Net earnings',
                  ),
                  StatCard(
                    label:    'Total Products',
                    value:    product.totalProducts.toDouble(),
                    icon:     Icons.inventory_2_rounded,
                    gradient: AppColors.warningGradient,
                    isCurrency: false,
                    sub:      '${product.lowStockCount} low stock',
                  ),
                  StatCard(
                    label:    'Low Stock',
                    value:    product.lowStockCount.toDouble(),
                    icon:     Icons.warning_amber_rounded,
                    gradient: AppColors.dangerGradient,
                    isCurrency: false,
                    sub:      '${product.outOfStockCount} out of stock',
                  ),
                ]),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing:  12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                ),
              ),
            ),

            // ── Quick Actions ─────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _sectionHeader('Quick Actions'),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: QuickActionsGrid(),
              ),
            ),

            // ── Sales Chart ───────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _sectionHeader('Weekly Sales'),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SalesChartWidget(dataPoints: report.weeklyChart),
              ),
            ),

            // ── Low Stock Alert ───────────────────────────
            if (product.lowStockProducts.isNotEmpty) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _sectionHeader('Low Stock Alert',
                      badge: product.lowStockProducts.length),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LowStockAlert(products: product.lowStockProducts),
                ),
              ),
            ],

            // ── Recent Sales ──────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _sectionHeader("Today's Sales",
                    badge: sale.todayBillCount),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: RecentSalesList(sales: sale.todaySales),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, {int? badge}) {
    return Row(children: [
      Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      if (badge != null && badge > 0) ...[
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text('$badge',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    ]);
  }
}
