// lib/models/sale_item_model.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Sale Item Model (line item inside a sale)
// ─────────────────────────────────────────────────────────────

class SaleItemModel {
  final String productId;
  final String productName;
  final String? barcode;
  final String? category;
  final int     quantity;
  final double  salePrice;   // price per unit at time of sale
  final double  costPrice;   // cost per unit at time of sale
  final double  discount;    // per-item discount amount

  const SaleItemModel({
    required this.productId,
    required this.productName,
    this.barcode,
    this.category,
    required this.quantity,
    required this.salePrice,
    required this.costPrice,
    this.discount = 0,
  });

  // ── Computed ───────────────────────────────────────────────
  double get subtotal  => salePrice * quantity;
  double get total     => subtotal - discount;
  double get profit    => (salePrice - costPrice) * quantity - discount;
  double get costTotal => costPrice * quantity;

  factory SaleItemModel.fromJson(Map<String, dynamic> json) => SaleItemModel(
        productId:   json['productId']   ?? '',
        productName: json['productName'] ?? '',
        barcode:     json['barcode'],
        category:    json['category'],
        quantity:    (json['quantity']   ?? 1) as int,
        salePrice:   (json['salePrice']  ?? 0).toDouble(),
        costPrice:   (json['costPrice']  ?? 0).toDouble(),
        discount:    (json['discount']   ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'productId':   productId,
        'productName': productName,
        'barcode':     barcode,
        'category':    category,
        'quantity':    quantity,
        'salePrice':   salePrice,
        'costPrice':   costPrice,
        'discount':    discount,
      };

  SaleItemModel copyWith({
    String? productId,
    String? productName,
    String? barcode,
    String? category,
    int?    quantity,
    double? salePrice,
    double? costPrice,
    double? discount,
  }) =>
      SaleItemModel(
        productId:   productId   ?? this.productId,
        productName: productName ?? this.productName,
        barcode:     barcode     ?? this.barcode,
        category:    category    ?? this.category,
        quantity:    quantity    ?? this.quantity,
        salePrice:   salePrice   ?? this.salePrice,
        costPrice:   costPrice   ?? this.costPrice,
        discount:    discount    ?? this.discount,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleItemModel && other.productId == productId;

  @override
  int get hashCode => productId.hashCode;

  @override
  String toString() =>
      'SaleItemModel($productName x$quantity @ $salePrice)';
}
