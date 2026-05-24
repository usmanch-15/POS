import 'package:cloud_firestore/cloud_firestore.dart';
import 'sale_item_model.dart';

// ✅ FIX: payment_dialog.dart lines 256, 269 — `upi` add kiya enum mein
enum PaymentMethod { cash, card, upi, split }
enum SaleStatus    { completed, refunded, partial }

extension PaymentMethodExt on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cash:  return 'Cash';
      case PaymentMethod.card:  return 'Card';
      case PaymentMethod.upi:   return 'UPI';   // ✅ FIX
      case PaymentMethod.split: return 'Split';
    }
  }
}

extension SaleStatusExt on SaleStatus {
  String get label {
    switch (this) {
      case SaleStatus.completed: return 'Completed';
      case SaleStatus.refunded:  return 'Refunded';
      case SaleStatus.partial:   return 'Partial Refund';
    }
  }
}

class SaleModel {
  final String              id;
  final String              billNumber;
  final String              businessId;
  final List<SaleItemModel> items;
  final double              subtotal;
  final double              discountAmount;
  final double              taxAmount;
  final double              taxRate;
  final double              total;
  final PaymentMethod       paymentMethod;
  final SaleStatus          status;
  final String?             customerId;
  final String?             customerName;
  final String?             customerPhone;
  final String?             cashierId;
  final String?             cashierName;
  final double              cashReceived;
  final double              changeGiven;
  final String?             note;
  final DateTime            createdAt;

  const SaleModel({
    required this.id,
    required this.billNumber,
    this.businessId     = '',
    required this.items,
    required this.subtotal,
    this.discountAmount = 0,
    this.taxAmount      = 0,
    this.taxRate        = 0,
    required this.total,
    this.paymentMethod  = PaymentMethod.cash,
    this.status         = SaleStatus.completed,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.cashierId,
    this.cashierName,
    this.cashReceived   = 0,
    this.changeGiven    = 0,
    this.note,
    required this.createdAt,
  });

  // ── Computed ───────────────────────────────────────────────
  int    get totalItems  => items.fold(0, (s, i) => s + i.quantity);
  double get totalProfit => items.fold(0.0, (s, i) => s + i.profit) - discountAmount;
  double get totalCost   => items.fold(0.0, (s, i) => s + i.costTotal);

  // ── Serialization ──────────────────────────────────────────
  static PaymentMethod _paymentFrom(String? s) {
    switch (s) {
      case 'card':  return PaymentMethod.card;
      case 'upi':   return PaymentMethod.upi;   // ✅ FIX
      case 'split': return PaymentMethod.split;
      default:      return PaymentMethod.cash;
    }
  }

  static SaleStatus _statusFrom(String? s) {
    switch (s) {
      case 'refunded': return SaleStatus.refunded;
      case 'partial':  return SaleStatus.partial;
      default:         return SaleStatus.completed;
    }
  }

  factory SaleModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return SaleModel(
      id:             docId,
      billNumber:     data['billNumber']    ?? '',
      businessId:     data['businessId']    ?? '',
      items:          (data['items'] as List<dynamic>? ?? [])
          .map((i) => SaleItemModel.fromJson(Map<String, dynamic>.from(i)))
          .toList(),
      subtotal:       (data['subtotal']       ?? 0).toDouble(),
      discountAmount: (data['discountAmount'] ?? 0).toDouble(),
      taxAmount:      (data['taxAmount']      ?? 0).toDouble(),
      taxRate:        (data['taxRate']        ?? 0).toDouble(),
      total:          (data['total']          ?? 0).toDouble(),
      paymentMethod:  _paymentFrom(data['paymentMethod']),
      status:         _statusFrom(data['status']),
      customerId:     data['customerId'],
      customerName:   data['customerName'],
      customerPhone:  data['customerPhone'],
      cashierId:      data['cashierId'],
      cashierName:    data['cashierName'],
      cashReceived:   (data['cashReceived']   ?? 0).toDouble(),
      changeGiven:    (data['changeGiven']    ?? 0).toDouble(),
      note:           data['note'],
      createdAt:      data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'billNumber':     billNumber,
    'businessId':     businessId,
    'items':          items.map((i) => i.toJson()).toList(),
    'subtotal':       subtotal,
    'discountAmount': discountAmount,
    'taxAmount':      taxAmount,
    'taxRate':        taxRate,
    'total':          total,
    'paymentMethod':  paymentMethod.name,
    'status':         status.name,
    'customerId':     customerId,
    'customerName':   customerName,
    'customerPhone':  customerPhone,
    'cashierId':      cashierId,
    'cashierName':    cashierName,
    'cashReceived':   cashReceived,
    'changeGiven':    changeGiven,
    'note':           note,
    'createdAt':      FieldValue.serverTimestamp(),
  };

  SaleModel copyWith({
    String?              id,
    String?              billNumber,
    String?              businessId,
    List<SaleItemModel>? items,
    double?              subtotal,
    double?              discountAmount,
    double?              taxAmount,
    double?              taxRate,
    double?              total,
    PaymentMethod?       paymentMethod,
    SaleStatus?          status,
    String?              customerId,
    String?              customerName,
    String?              customerPhone,
    String?              cashierId,
    String?              cashierName,
    double?              cashReceived,
    double?              changeGiven,
    String?              note,
    DateTime?            createdAt,
  }) =>
      SaleModel(
        id:             id             ?? this.id,
        billNumber:     billNumber     ?? this.billNumber,
        businessId:     businessId     ?? this.businessId,
        items:          items          ?? this.items,
        subtotal:       subtotal       ?? this.subtotal,
        discountAmount: discountAmount ?? this.discountAmount,
        taxAmount:      taxAmount      ?? this.taxAmount,
        taxRate:        taxRate        ?? this.taxRate,
        total:          total          ?? this.total,
        paymentMethod:  paymentMethod  ?? this.paymentMethod,
        status:         status         ?? this.status,
        customerId:     customerId     ?? this.customerId,
        customerName:   customerName   ?? this.customerName,
        customerPhone:  customerPhone  ?? this.customerPhone,
        cashierId:      cashierId      ?? this.cashierId,
        cashierName:    cashierName    ?? this.cashierName,
        cashReceived:   cashReceived   ?? this.cashReceived,
        changeGiven:    changeGiven    ?? this.changeGiven,
        note:           note           ?? this.note,
        createdAt:      createdAt      ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SaleModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SaleModel($billNumber, total: $total)';
}