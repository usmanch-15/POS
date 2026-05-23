import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale_model.dart';
import '../models/sale_item_model.dart';
import '../models/stock_model.dart';
import '../services/product_service.dart';

class SaleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _sales => _db.collection('sales');
  CollectionReference get _stock => _db.collection('stock_movements');
  CollectionReference get _prods => _db.collection('products');
  DocumentReference get _counter => _db.collection('meta').doc('bill_counter');

  // ── Stream today's sales ────────────────────────────────────
  Stream<List<SaleModel>> streamTodaySales() {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day);
    final to = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return _sales
        .where('businessId', isEqualTo: ProductService.cachedBusinessId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(to))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapSales);
  }

  // ── Stream all sales ────────────────────────────────────────
  Stream<List<SaleModel>> streamSales({int limit = 50}) {
    return _sales
        .where('businessId', isEqualTo: ProductService.cachedBusinessId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(_mapSales);
  }

  // ── Search by bill number ───────────────────────────────────
  Future<List<SaleModel>> getSalesByBillNumber(String billNumber) async {
    final snap = await _sales
        .where('businessId', isEqualTo: ProductService.cachedBusinessId)
        .where('billNumber', isEqualTo: billNumber.toUpperCase().trim())
        .limit(10)
        .get();
    return _mapSales(snap);
  }

  // ── Filter by date range ────────────────────────────────────
  Future<List<SaleModel>> getSalesInRange(DateTime from, DateTime to) async {
    final snap = await _sales
        .where('businessId', isEqualTo: ProductService.cachedBusinessId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(to))
        .orderBy('createdAt', descending: true)
        .get();
    return _mapSales(snap);
  }

  // ── Get single sale ─────────────────────────────────────────
  Future<SaleModel?> getSale(String id) async {
    final doc = await _sales.doc(id).get();
    if (!doc.exists) return null;
    return SaleModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
  }

  // ── Complete a sale (Firestore transaction) ─────────────────
  Future<SaleModel> completeSale(SaleModel sale) async {
    late SaleModel saved;
    await _db.runTransaction((txn) async {
      // Atomic bill counter
      final counterSnap = await txn.get(_counter);
      int nextNum = 1;
      if (counterSnap.exists) {
        nextNum =
            ((counterSnap.data() as Map<String, dynamic>)['count'] ?? 0) + 1;
      }
      txn.set(_counter, {'count': nextNum}, SetOptions(merge: true));
      final billNo = 'BILL-${nextNum.toString().padLeft(4, '0')}';

      // Har product ki stock transaction mein read karo
      final Map<String, int> prevQtyMap = {};
      for (final item in sale.items) {
        final snap = await txn.get(_prods.doc(item.productId));
        if (snap.exists) {
          prevQtyMap[item.productId] =
              (snap.data() as Map<String, dynamic>)['quantity'] as int? ?? 0;
        }
      }

      final saleRef = _sales.doc();
      saved = sale.copyWith(
        id: saleRef.id,
        billNumber: billNo,
        businessId: ProductService.cachedBusinessId,
      );
      txn.set(saleRef, saved.toFirestore());

      for (final item in sale.items) {
        final prevStock = prevQtyMap[item.productId] ?? 0;
        final newStock = (prevStock - item.quantity).clamp(0, prevStock);
        txn.update(_prods.doc(item.productId), {
          'quantity': FieldValue.increment(-item.quantity),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        final movRef = _stock.doc();
        txn.set(
            movRef,
            StockMovement(
              id: movRef.id,
              productId: item.productId,
              productName: item.productName,
              type: StockMovementType.saleDeduction,
              quantity: item.quantity,
              previousStock: prevStock,
              newStock: newStock,
              referenceId: saleRef.id,
              createdAt: DateTime.now(),
              businessId: ProductService.cachedBusinessId, // ✅ FIX
            ).toFirestore());
      }
    });
    return saved;
  }

  // ── Poora refund ────────────────────────────────────────────
  Future<void> refundSale(String saleId) async {
    final sale = await getSale(saleId);
    if (sale == null) return;
    if (sale.status == SaleStatus.refunded) return;

    await _partialOrFullRefund(
      saleId: saleId,
      sale: sale,
      itemsToRefund: sale.items,
      isFullRefund: true,
    );
  }

  // ── Partial refund — selected items ────────────────────────
  Future<void> partialRefund({
    required String saleId,
    required List<SaleItemModel> itemsToRefund,
  }) async {
    if (itemsToRefund.isEmpty) return;
    final sale = await getSale(saleId);
    if (sale == null) return;
    if (sale.status == SaleStatus.refunded) {
      throw Exception('Yeh sale pehle se poori refund ho chuki hai');
    }

    await _partialOrFullRefund(
      saleId: saleId,
      sale: sale,
      itemsToRefund: itemsToRefund,
      isFullRefund: false,
    );
  }

  // ── Internal: refund transaction ───────────────────────────
  Future<void> _partialOrFullRefund({
    required String saleId,
    required SaleModel sale,
    required List<SaleItemModel> itemsToRefund,
    required bool isFullRefund,
  }) async {
    await _db.runTransaction((txn) async {
      txn.update(_sales.doc(saleId), {
        'status': isFullRefund
            ? SaleStatus.refunded.name
            : SaleStatus.partial.name,
        'refundedAt': FieldValue.serverTimestamp(),
        'refundedItems': itemsToRefund
            .map((i) => {'productId': i.productId, 'quantity': i.quantity})
            .toList(),
      });

      for (final item in itemsToRefund) {
        final prodRef = _prods.doc(item.productId);
        final prodSnap = await txn.get(prodRef);
        final prevQty = prodSnap.exists
            ? (prodSnap.data() as Map<String, dynamic>)['quantity'] as int? ??
            0
            : 0;
        final newQty = prevQty + item.quantity;

        txn.update(prodRef, {
          'quantity': FieldValue.increment(item.quantity),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        final movRef = _stock.doc();
        txn.set(
            movRef,
            StockMovement(
              id: movRef.id,
              productId: item.productId,
              productName: item.productName,
              type: StockMovementType.returnIn,
              quantity: item.quantity,
              previousStock: prevQty,
              newStock: newQty,
              referenceId: saleId,
              createdAt: DateTime.now(),
              businessId: ProductService.cachedBusinessId, // ✅ FIX (line 217)
            ).toFirestore());
      }
    });
  }

  // ── Helper ──────────────────────────────────────────────────
  List<SaleModel> _mapSales(QuerySnapshot snap) => snap.docs
      .map((d) =>
      SaleModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
      .toList();
}