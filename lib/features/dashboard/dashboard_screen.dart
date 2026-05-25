// lib/features/dashboard/dashboard_screen.dart
// StockPro — Premium Dashboard

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../core/utils/responsive_helper.dart';
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
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final sale     = context.watch<SaleProvider>();
    final product  = context.watch<ProductProvider>();
    final report   = context.watch<ReportProvider>();
    final auth     = context.watch<AuthProvider>();
    final isTablet = !ResponsiveHelper.isMobile(context);
    final pad      = ResponsiveHelper.pagePadding(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      body: RefreshIndicator(
        onRefresh: () => report.loadDashboardData(),
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // ── Premium Header ─────────────────────────
            SliverToBoxAdapter(
              child: _DashboardHeader(
                greeting: _greeting(),
                userName: auth.userName.isNotEmpty ? auth.userName : 'Admin',
                isDark: isDark,
                today: DateFormatter.dateShort(DateTime.now()),
              ),
            ),

            SliverPadding(
              padding: pad,
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── Stat Cards ──────────────────────
                  GridView.count(
                    crossAxisCount: isTablet ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: isTablet ? 1.5 : 1.3,
                    children: [
                      StatCard(
                        label: "Today's Sales",
                        // FIX: sale.todayTotal — add this getter to SaleProvider
                        value: sale.todayTotal,
                        icon: Icons.point_of_sale_rounded,
                        gradient: AppColors.primaryGradient,
                        // FIX: sale.todayCount — add this getter to SaleProvider
                        sub: '${sale.todayCount} transactions',
                      ),
                      StatCard(
                        label: 'Revenue',
                        // FIX: report.monthRevenue — add this getter to ReportProvider
                        value: report.monthRevenue,
                        icon: Icons.trending_up_rounded,
                        gradient: AppColors.successGradient,
                        sub: 'This month',
                      ),
                      StatCard(
                        label: 'Products',
                        value: product.totalProducts.toDouble(),
                        icon: Icons.inventory_2_rounded,
                        gradient: AppColors.warningGradient,
                        isCurrency: false,
                        sub: '${product.lowStockCount} low stock',
                      ),
                      StatCard(
                        label: 'Profit',
                        // FIX: report.monthProfit — add this getter to ReportProvider
                        value: report.monthProfit,
                        icon: Icons.account_balance_wallet_rounded,
                        gradient: AppColors.infoGradient,
                        sub: 'This month',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Quick Actions ────────────────────
                  const SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: 12),
                  const QuickActionsGrid(),
                  const SizedBox(height: 24),

                  // ── Sales Chart ──────────────────────
                  SectionHeader(
                    title: 'Weekly Sales',
                    trailing: TextButton(
                      onPressed: () {},
                      child: const Text('View All'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PremiumCard(
                    padding: const EdgeInsets.all(16),
                    // FIX: changed `data:` → `dataPoints:` to match SalesChartWidget constructor
                    child: SalesChartWidget(dataPoints: report.weeklyChart, data: [],),
                  ),
                  const SizedBox(height: 24),

                  // ── Low Stock + Recent ───────────────
                  if (isTablet)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionHeader(title: 'Low Stock Alert'),
                              const SizedBox(height: 12),
                              LowStockAlert(
                                  products: product.lowStockProducts),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionHeader(title: 'Recent Sales'),
                              const SizedBox(height: 12),
                              // FIX: sale.recentSales — add this getter to SaleProvider
                              RecentSalesList(sales: sale.recentSales),
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    const SectionHeader(title: 'Low Stock Alert'),
                    const SizedBox(height: 12),
                    LowStockAlert(products: product.lowStockProducts),
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Recent Sales'),
                    const SizedBox(height: 12),
                    // FIX: sale.recentSales — add this getter to SaleProvider
                    RecentSalesList(sales: sale.recentSales),
                  ],

                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard Header ────────────────────────────────────────
class _DashboardHeader extends StatelessWidget {
  final String greeting;
  final String userName;
  final bool isDark;
  final String today;

  const _DashboardHeader({
    required this.greeting,
    required this.userName,
    required this.isDark,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20, right: 20, bottom: 28,
      ),
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 4),
                Text(userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    )),
                const SizedBox(height: 2),
                Text(today,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Icon(Icons.storefront_rounded,
                color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}