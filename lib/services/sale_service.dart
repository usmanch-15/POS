// lib/services/sale_service.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Sale / Billing Firestore Service
// ─────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale_model.dart';
import '../models/stock_model.dart';

class SaleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _sales  => _db.collection('sales');
  CollectionReference get _stock  => _db.collection('stock_movements');
  CollectionReference get _prods  => _db.collection('products');

  // ── Stream today's sales ───────────────────────────────────
  Stream<List<SaleModel>> streamTodaySales() {
    final start = DateTime.now();
    final from  = DateTime(start.year, start.month, start.day);
    final to    = DateTime(start.year, start.month, start.day, 23, 59, 59);
    return _sales
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('createdAt', isLessThanOrEqualTo:    Timestamp.fromDate(to))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapSales);
  }

  // ── Stream all sales ───────────────────────────────────────
  Stream<List<SaleModel>> streamSales({int limit = 50}) {
    return _sales
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(_mapSales);
  }

  // ── Sales in date range ────────────────────────────────────
  Future<List<SaleModel>> getSalesInRange(DateTime from, DateTime to) async {
    final snap = await _sales
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('createdAt', isLessThanOrEqualTo:    Timestamp.fromDate(to))
        .orderBy('createdAt', descending: true)
        .get();
    return _mapSales(snap);
  }

  // ── Get single sale ────────────────────────────────────────
  Future<SaleModel?> getSale(String id) async {
    final doc = await _sales.doc(id).get();
    if (!doc.exists) return null;
    return SaleModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
  }

  // ── Complete a sale (Firestore transaction) ────────────────
  Future<SaleModel> completeSale(SaleModel sale) async {
    late SaleModel saved;

    await _db.runTransaction((txn) async {
      // 1. Write sale document
      final saleRef = _sales.doc();
      final billNo  = await _nextBillNumber();
      saved = sale.copyWith(id: saleRef.id, billNumber: billNo);
      txn.set(saleRef, saved.toFirestore());

      // 2. Decrement stock for each item
      for (final item in sale.items) {
        final prodRef = _prods.doc(item.productId);
        txn.update(prodRef, {
          'quantity':  FieldValue.increment(-item.quantity),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 3. Write stock movement
        final movRef = _stock.doc();
        final mov = StockMovement(
          id:            movRef.id,
          productId:     item.productId,
          productName:   item.productName,
          type:          StockMovementType.saleDeduction,
          quantity:      item.quantity,
          previousStock: 0, // will be updated by inventory service
          newStock:      0,
          referenceId:   saleRef.id,
          createdAt:     DateTime.now(),
        );
        txn.set(movRef, mov.toFirestore());
      }
    });

    return saved;
  }

  // ── Refund a sale ──────────────────────────────────────────
  Future<void> refundSale(String saleId) async {
    final sale = await getSale(saleId);
    if (sale == null) return;

    await _db.runTransaction((txn) async {
      // Mark sale as refunded
      txn.update(_sales.doc(saleId), {'status': SaleStatus.refunded.name});

      // Restore stock
      for (final item in sale.items) {
        txn.update(_prods.doc(item.productId), {
          'quantity':  FieldValue.increment(item.quantity),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // ── Generate bill number: BILL-0001 ───────────────────────
  Future<String> _nextBillNumber() async {
    final snap = await _sales
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
    int next = 1;
    if (snap.docs.isNotEmpty) {
      final last = (snap.docs.first.data() as Map<String, dynamic>)['billNumber'] as String? ?? 'BILL-0000';
      final num  = int.tryParse(last.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
      next = num + 1;
    }
    return 'BILL-${next.toString().padLeft(4, '0')}';
  }

  // ── Helper ─────────────────────────────────────────────────
  List<SaleModel> _mapSales(QuerySnapshot snap) => snap.docs
      .map((d) => SaleModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
      .toList();
}
