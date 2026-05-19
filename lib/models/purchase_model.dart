// lib/models/purchase_model.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Purchase / Stock-in Order Model
// ─────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

enum PurchaseStatus { pending, received, partial, cancelled }

extension PurchaseStatusExt on PurchaseStatus {
  String get label {
    switch (this) {
      case PurchaseStatus.pending:   return 'Pending';
      case PurchaseStatus.received:  return 'Received';
      case PurchaseStatus.partial:   return 'Partial';
      case PurchaseStatus.cancelled: return 'Cancelled';
    }
  }
}

class PurchaseItem {
  final String productId;
  final String productName;
  final int    quantity;
  final double costPrice;

  const PurchaseItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.costPrice,
  });

  double get total => quantity * costPrice;

  factory PurchaseItem.fromJson(Map<String, dynamic> json) => PurchaseItem(
    productId:   json['productId']   ?? '',
    productName: json['productName'] ?? '',
    quantity:    (json['quantity']   ?? 0) as int,
    costPrice:   (json['costPrice']  ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'productId':   productId,
    'productName': productName,
    'quantity':    quantity,
    'costPrice':   costPrice,
  };
}

class PurchaseModel {
  final String         id;
  final String?        supplierId;
  final String?        supplierName;
  final List<PurchaseItem> items;
  final double         totalAmount;
  final double         amountPaid;
  final PurchaseStatus status;
  final String?        note;
  final String?        invoiceNumber;
  final DateTime       createdAt;
  final DateTime?      receivedAt;

  const PurchaseModel({
    required this.id,
    this.supplierId,
    this.supplierName,
    required this.items,
    required this.totalAmount,
    this.amountPaid     = 0,
    this.status         = PurchaseStatus.pending,
    this.note,
    this.invoiceNumber,
    required this.createdAt,
    this.receivedAt,
  });

  double get balance => totalAmount - amountPaid;
  bool   get isPaid  => amountPaid >= totalAmount;

  static PurchaseStatus _statusFrom(String? s) {
    switch (s) {
      case 'received':  return PurchaseStatus.received;
      case 'partial':   return PurchaseStatus.partial;
      case 'cancelled': return PurchaseStatus.cancelled;
      default:          return PurchaseStatus.pending;
    }
  }

  factory PurchaseModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return PurchaseModel(
      id:            docId,
      supplierId:    data['supplierId'],
      supplierName:  data['supplierName'],
      items:         (data['items'] as List<dynamic>? ?? [])
          .map((i) => PurchaseItem.fromJson(Map<String, dynamic>.from(i)))
          .toList(),
      totalAmount:   (data['totalAmount']  ?? 0).toDouble(),
      amountPaid:    (data['amountPaid']   ?? 0).toDouble(),
      status:        _statusFrom(data['status']),
      note:          data['note'],
      invoiceNumber: data['invoiceNumber'],
      createdAt:     data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      receivedAt:    data['receivedAt'] != null
          ? (data['receivedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'supplierId':    supplierId,
    'supplierName':  supplierName,
    'items':         items.map((i) => i.toJson()).toList(),
    'totalAmount':   totalAmount,
    'amountPaid':    amountPaid,
    'status':        status.name,
    'note':          note,
    'invoiceNumber': invoiceNumber,
    'createdAt':     FieldValue.serverTimestamp(),
    'receivedAt':    receivedAt != null ? Timestamp.fromDate(receivedAt!) : null,
  };

  PurchaseModel copyWith({
    String? id,
    String? supplierId,
    String? supplierName,
    List<PurchaseItem>? items,
    double? totalAmount,
    double? amountPaid,
    PurchaseStatus? status,
    String? note,
    String? invoiceNumber,
    DateTime? createdAt,
    DateTime? receivedAt,
  }) =>
      PurchaseModel(
        id:            id            ?? this.id,
        supplierId:    supplierId    ?? this.supplierId,
        supplierName:  supplierName  ?? this.supplierName,
        items:         items         ?? this.items,
        totalAmount:   totalAmount   ?? this.totalAmount,
        amountPaid:    amountPaid    ?? this.amountPaid,
        status:        status        ?? this.status,
        note:          note          ?? this.note,
        invoiceNumber: invoiceNumber ?? this.invoiceNumber,
        createdAt:     createdAt     ?? this.createdAt,
        receivedAt:    receivedAt    ?? this.receivedAt,
      );
}
