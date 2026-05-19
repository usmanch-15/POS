// lib/models/report_model.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Report Data Models
// ─────────────────────────────────────────────────────────────

/// Daily Sales Summary
class DailySummary {
  final DateTime date;
  final double   totalSales;
  final double   totalCost;
  final double   totalProfit;
  final double   totalDiscount;
  final int      billCount;
  final int      itemsSold;

  const DailySummary({
    required this.date,
    required this.totalSales,
    required this.totalCost,
    required this.totalProfit,
    required this.totalDiscount,
    required this.billCount,
    required this.itemsSold,
  });

  double get profitMargin =>
      totalSales > 0 ? (totalProfit / totalSales) * 100 : 0;

  double get avgBillValue =>
      billCount > 0 ? totalSales / billCount : 0;
}

/// Monthly Summary (aggregated)
class MonthlySummary {
  final int    month;
  final int    year;
  final double totalSales;
  final double totalProfit;
  final double totalExpenses;
  final int    billCount;

  const MonthlySummary({
    required this.month,
    required this.year,
    required this.totalSales,
    required this.totalProfit,
    required this.totalExpenses,
    required this.billCount,
  });

  double get netProfit => totalProfit - totalExpenses;

  String get monthLabel {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[month]} $year';
  }
}

/// Top selling product entry
class TopProduct {
  final String productId;
  final String productName;
  final String category;
  final int    quantitySold;
  final double revenue;
  final double profit;

  const TopProduct({
    required this.productId,
    required this.productName,
    required this.category,
    required this.quantitySold,
    required this.revenue,
    required this.profit,
  });
}

/// Category-wise sales breakdown
class CategorySales {
  final String category;
  final double totalSales;
  final double totalProfit;
  final int    itemsSold;
  final double percentage; // share of total sales

  const CategorySales({
    required this.category,
    required this.totalSales,
    required this.totalProfit,
    required this.itemsSold,
    required this.percentage,
  });
}

/// Profit & Loss summary for a period
class ProfitLossSummary {
  final DateTime from;
  final DateTime to;
  final double   grossRevenue;
  final double   costOfGoods;
  final double   grossProfit;
  final double   totalExpenses;
  final double   netProfit;
  final int      totalBills;
  final double   totalDiscount;

  const ProfitLossSummary({
    required this.from,
    required this.to,
    required this.grossRevenue,
    required this.costOfGoods,
    required this.grossProfit,
    required this.totalExpenses,
    required this.netProfit,
    required this.totalBills,
    required this.totalDiscount,
  });

  double get profitMarginPct =>
      grossRevenue > 0 ? (netProfit / grossRevenue) * 100 : 0;

  bool get isProfit => netProfit >= 0;
}

/// Chart data point
class ChartDataPoint {
  final String label;   // x-axis label (e.g. "Mon", "Jan")
  final double value;   // y-axis value
  final double? value2; // second series (optional)

  const ChartDataPoint({
    required this.label,
    required this.value,
    this.value2,
  });
}
