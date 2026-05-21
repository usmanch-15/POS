// lib/services/report_service.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Reports & Analytics Service
//  FIX: getWeeklySalesChart() 7 alag Firestore calls karta tha.
//       Ab single date range query se sab kuch ek call mein
//       fetch hota hai — 7x reads se 1x read.
// ─────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale_model.dart';
import '../models/report_model.dart';
import '../models/expense_model.dart';

class ReportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _sales    => _db.collection('sales');
  CollectionReference get _expenses => _db.collection('expenses');

  // ── Daily Summary ──────────────────────────────────────────
  Future<DailySummary> getDailySummary(DateTime date) async {
    final from = DateTime(date.year, date.month, date.day);
    final to   = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final snap = await _sales
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('createdAt', isLessThanOrEqualTo:    Timestamp.fromDate(to))
        .where('status', isEqualTo: SaleStatus.completed.name)
        .get();

    final sales = snap.docs
        .map((d) => SaleModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
        .toList();

    return DailySummary(
      date:          date,
      totalSales:    sales.fold(0.0, (s, sale) => s + sale.total),
      totalCost:     sales.fold(0.0, (s, sale) => s + sale.totalCost),
      totalProfit:   sales.fold(0.0, (s, sale) => s + sale.totalProfit),
      totalDiscount: sales.fold(0.0, (s, sale) => s + sale.discountAmount),
      billCount:     sales.length,
      itemsSold:     sales.fold(0, (s, sale) => s + sale.totalItems),
    );
  }

  // ── Last 7 days chart data — FIX ──────────────────────────
  // PEHLE: Loop mein 7 baar getDailySummary() call hota tha.
  //        Har call = 1 Firestore query → total 7 queries.
  //
  // AB:    Single query se poore 7 din ka data ek baar mein aata hai.
  //        Phir Dart mein groupBy karke har din ki summary banate hain.
  //        7 reads → 1 read.
  Future<List<ChartDataPoint>> getWeeklySalesChart() async {
    final now  = DateTime.now();
    final from = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6)); // 7 din pehle ki subah
    final to   = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // Single query — 7 din ka poora data
    final snap = await _sales
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('createdAt', isLessThanOrEqualTo:    Timestamp.fromDate(to))
        .where('status', isEqualTo: SaleStatus.completed.name)
        .get();

    final sales = snap.docs
        .map((d) => SaleModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
        .toList();

    // Dart mein groupBy karo — date ke hisab se
    final Map<String, List<SaleModel>> grouped = {};
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = '${day.year}-${day.month}-${day.day}';
      grouped[key] = [];
    }
    for (final sale in sales) {
      final d   = sale.createdAt;
      final key = '${d.year}-${d.month}-${d.day}';
      grouped[key]?.add(sale);
    }

    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final List<ChartDataPoint> points = [];

    for (int i = 6; i >= 0; i--) {
      final day    = now.subtract(Duration(days: i));
      final key    = '${day.year}-${day.month}-${day.day}';
      final daySales = grouped[key] ?? [];

      points.add(ChartDataPoint(
        label:  dayNames[day.weekday - 1],
        value:  daySales.fold(0.0, (s, sale) => s + sale.total),
        value2: daySales.fold(0.0, (s, sale) => s! + sale.totalProfit),
      ));
    }

    return points;
  }

  // ── Monthly summary ────────────────────────────────────────
  Future<MonthlySummary> getMonthlySummary(int month, int year) async {
    final from = DateTime(year, month, 1);
    final to   = DateTime(year, month + 1, 0, 23, 59, 59);

    final salesSnap = await _sales
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('createdAt', isLessThanOrEqualTo:    Timestamp.fromDate(to))
        .where('status', isEqualTo: SaleStatus.completed.name)
        .get();

    final expSnap = await _expenses
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('date', isLessThanOrEqualTo:    Timestamp.fromDate(to))
        .get();

    final sales = salesSnap.docs
        .map((d) => SaleModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
        .toList();

    final totalExpenses = expSnap.docs
        .fold(0.0, (s, d) => s + ((d.data() as Map)['amount'] ?? 0).toDouble());

    return MonthlySummary(
      month:         month,
      year:          year,
      totalSales:    sales.fold(0.0, (s, sale) => s + sale.total),
      totalProfit:   sales.fold(0.0, (s, sale) => s + sale.totalProfit),
      totalExpenses: totalExpenses,
      billCount:     sales.length,
    );
  }

  // ── Profit & Loss for range ────────────────────────────────
  Future<ProfitLossSummary> getProfitLoss(DateTime from, DateTime to) async {
    final salesSnap = await _sales
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('createdAt', isLessThanOrEqualTo:    Timestamp.fromDate(to))
        .where('status', isEqualTo: SaleStatus.completed.name)
        .get();

    final expSnap = await _expenses
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('date', isLessThanOrEqualTo:    Timestamp.fromDate(to))
        .get();

    final sales = salesSnap.docs
        .map((d) => SaleModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
        .toList();

    final grossRevenue  = sales.fold(0.0, (s, sale) => s + sale.total);
    final costOfGoods   = sales.fold(0.0, (s, sale) => s + sale.totalCost);
    final grossProfit   = grossRevenue - costOfGoods;
    final totalExpenses = expSnap.docs
        .fold(0.0, (s, d) => s + ((d.data() as Map)['amount'] ?? 0).toDouble());
    final totalDiscount = sales.fold(0.0, (s, sale) => s + sale.discountAmount);

    return ProfitLossSummary(
      from:          from,
      to:            to,
      grossRevenue:  grossRevenue,
      costOfGoods:   costOfGoods,
      grossProfit:   grossProfit,
      totalExpenses: totalExpenses,
      netProfit:     grossProfit - totalExpenses,
      totalBills:    sales.length,
      totalDiscount: totalDiscount,
    );
  }

  // ── Top products ───────────────────────────────────────────
  Future<List<TopProduct>> getTopProducts({
    required DateTime from,
    required DateTime to,
    int limit = 10,
  }) async {
    final snap = await _sales
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('createdAt', isLessThanOrEqualTo:    Timestamp.fromDate(to))
        .where('status', isEqualTo: SaleStatus.completed.name)
        .get();

    final sales = snap.docs
        .map((d) => SaleModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
        .toList();

    final Map<String, TopProduct> map = {};
    for (final sale in sales) {
      for (final item in sale.items) {
        if (map.containsKey(item.productId)) {
          final existing = map[item.productId]!;
          map[item.productId] = TopProduct(
            productId:    item.productId,
            productName:  item.productName,
            category:     item.category ?? '',
            quantitySold: existing.quantitySold + item.quantity,
            revenue:      existing.revenue + item.total,
            profit:       existing.profit  + item.profit,
          );
        } else {
          map[item.productId] = TopProduct(
            productId:    item.productId,
            productName:  item.productName,
            category:     item.category ?? '',
            quantitySold: item.quantity,
            revenue:      item.total,
            profit:       item.profit,
          );
        }
      }
    }

    final sorted = map.values.toList()
      ..sort((a, b) => b.quantitySold.compareTo(a.quantitySold));
    return sorted.take(limit).toList();
  }

  // ── Category breakdown ─────────────────────────────────────
  Future<List<CategorySales>> getCategorySales({
    required DateTime from,
    required DateTime to,
  }) async {
    final snap = await _sales
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('createdAt', isLessThanOrEqualTo:    Timestamp.fromDate(to))
        .where('status', isEqualTo: SaleStatus.completed.name)
        .get();

    final sales = snap.docs
        .map((d) => SaleModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
        .toList();

    final Map<String, Map<String, double>> catMap = {};
    double grandTotal = 0;

    for (final sale in sales) {
      for (final item in sale.items) {
        final cat = item.category ?? 'Other';
        catMap.putIfAbsent(cat, () => {'sales': 0, 'profit': 0, 'qty': 0});
        catMap[cat]!['sales']  = (catMap[cat]!['sales']  ?? 0) + item.total;
        catMap[cat]!['profit'] = (catMap[cat]!['profit'] ?? 0) + item.profit;
        catMap[cat]!['qty']    = (catMap[cat]!['qty']    ?? 0) + item.quantity;
        grandTotal += item.total;
      }
    }

    return catMap.entries.map((e) => CategorySales(
      category:    e.key,
      totalSales:  e.value['sales']  ?? 0,
      totalProfit: e.value['profit'] ?? 0,
      itemsSold:   (e.value['qty']   ?? 0).toInt(),
      percentage:  grandTotal > 0 ? ((e.value['sales'] ?? 0) / grandTotal) * 100 : 0,
    )).toList()
      ..sort((a, b) => b.totalSales.compareTo(a.totalSales));
  }
}