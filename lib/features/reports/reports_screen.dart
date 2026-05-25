// lib/features/reports/reports_screen.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Reports Screen
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/report_provider.dart';
import '../../widgets/loading_overlay.dart';
import 'widgets/report_card.dart';
import 'widgets/sales_line_chart.dart';
import 'widgets/profit_bar_chart.dart' hide CategoryPieChart;
import 'widgets/category_pie_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  void _loadAll() {
    final rp = context.read<ReportProvider>();
    final now = DateTime.now();
    rp.loadDailySummary();
    rp.loadMonthlySummary();
    rp.loadWeeklyChart();
    rp.loadTopProducts(DateTime(now.year, now.month, 1), now);
    rp.loadCategorySales(DateTime(now.year, now.month, 1), now);
    rp.loadProfitLoss(DateTime(now.year, now.month, 1), now);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rp     = context.watch<ReportProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        title: const Text('Reports',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primary,
          unselectedLabelColor:
              isDark ? AppColors.darkText3 : AppColors.lightText3,
          indicatorColor: AppColors.primary,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'This Month'),
            Tab(text: 'P&L'),
          ],
        ),
      ),
      body: rp.isLoading
          ? const InlineLoader()
          : TabBarView(
              controller: _tab,
              children: [
                _TodayTab(rp: rp),
                _MonthTab(rp: rp),
                _ProfitTab(rp: rp),
              ],
            ),
    );
  }
}

// ── Today Tab ─────────────────────────────────────────────────
class _TodayTab extends StatelessWidget {
  final ReportProvider rp;
  const _TodayTab({required this.rp});

  @override
  Widget build(BuildContext context) {
    final s = rp.dailySummary;
    if (s == null) return const InlineLoader();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(DateFormatter.dateLong(DateTime.now()),
            style: const TextStyle(
                fontSize: 13, color: AppColors.lightText3)),
        const SizedBox(height: 12),
        // Stat cards
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.5,
          children: [
            ReportCard(label: 'Revenue',    value: s.totalSales,    gradient: AppColors.primaryGradient, icon: null,),
            ReportCard(label: 'Profit',     value: s.totalProfit,   gradient: AppColors.successGradient),
            ReportCard(label: 'Discount',   value: s.totalDiscount, gradient: AppColors.warningGradient),
            ReportCard(label: 'Bills',      value: s.billCount.toDouble(), gradient: AppColors.dangerGradient, isCurrency: false),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Weekly Trend',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        SalesLineChart(dataPoints: rp.weeklyChart),
        const SizedBox(height: 20),
        const Text('Top Products',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        ...rp.topProducts.take(5).map((p) => _TopProductTile(
              rank:     rp.topProducts.indexOf(p) + 1,
              name:     p.productName,
              qty:      p.quantitySold,
              revenue:  p.revenue,
            )),
      ],
    );
  }
}

// ── Month Tab ─────────────────────────────────────────────────
class _MonthTab extends StatelessWidget {
  final ReportProvider rp;
  const _MonthTab({required this.rp});

  @override
  Widget build(BuildContext context) {
    final s = rp.monthlySummary;
    if (s == null) return const InlineLoader();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(s.monthLabel,
            style: const TextStyle(
                fontSize: 13, color: AppColors.lightText3)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.5,
          children: [
            ReportCard(label: 'Revenue',   value: s.totalSales,    gradient: AppColors.primaryGradient),
            ReportCard(label: 'Gross Profit', value: s.totalProfit, gradient: AppColors.successGradient),
            ReportCard(label: 'Expenses',  value: s.totalExpenses, gradient: AppColors.warningGradient),
            ReportCard(label: 'Net Profit', value: s.netProfit,    gradient: AppColors.dangerGradient, icon: null,),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Category Breakdown',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        CategoryPieChart(data: rp.categorySales),
      ],
    );
  }
}

// ── P&L Tab ───────────────────────────────────────────────────
class _ProfitTab extends StatelessWidget {
  final ReportProvider rp;
  const _ProfitTab({required this.rp});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pl     = rp.profitLoss;
    if (pl == null) return const InlineLoader();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: pl.isProfit
                ? AppColors.successGradient
                : AppColors.dangerGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            const Text('Net Profit / Loss',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 6),
            Text(CurrencyFormatter.format(pl.netProfit.abs()),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700)),
            Text(pl.isProfit ? 'PROFIT ▲' : 'LOSS ▼',
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
        const SizedBox(height: 16),
        _plRow('Gross Revenue',   pl.grossRevenue,  isDark),
        _plRow('Cost of Goods',   pl.costOfGoods,   isDark, negative: true),
        _plRow('Gross Profit',    pl.grossProfit,   isDark, bold: true),
        const Divider(height: 24),
        _plRow('Total Expenses',  pl.totalExpenses, isDark, negative: true),
        _plRow('Discounts Given', pl.totalDiscount, isDark, negative: true),
        const Divider(height: 24),
        _plRow('Net Profit',      pl.netProfit,     isDark,
            bold: true,
            color: pl.isProfit ? AppColors.success : AppColors.danger),
        const SizedBox(height: 20),
        const Text('Monthly Comparison',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        ProfitBarChart(dataPoints: rp.weeklyChart),
      ],
    );
  }

  Widget _plRow(String label, double value, bool isDark,
      {bool negative = false, bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
                  color: isDark ? AppColors.darkText2 : AppColors.lightText2)),
          Text(
            '${negative ? '- ' : ''}${CurrencyFormatter.format(value)}',
            style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: color ??
                    (isDark ? Colors.white : AppColors.lightText1)),
          ),
        ],
      ),
    );
  }
}

// ── Top product tile ──────────────────────────────────────────
class _TopProductTile extends StatelessWidget {
  final int    rank;
  final String name;
  final int    qty;
  final double revenue;
  const _TopProductTile({
    required this.rank,
    required this.name,
    required this.qty,
    required this.revenue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text('$rank',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis)),
        Text('$qty sold',
            style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkText3 : AppColors.lightText3)),
        const SizedBox(width: 10),
        Text(CurrencyFormatter.format(revenue),
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.success)),
      ]),
    );
  }
}
