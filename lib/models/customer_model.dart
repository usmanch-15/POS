// lib/models/customer_model.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Customer Model
// ─────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final double totalPurchases;
  final int    visitCount;
  final double loyaltyPoints;
  final DateTime createdAt;
  final DateTime? lastVisit;

  const CustomerModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.totalPurchases = 0,
    this.visitCount     = 0,
    this.loyaltyPoints  = 0,
    required this.createdAt,
    this.lastVisit,
  });

  // ── Computed ───────────────────────────────────────────────
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get loyaltyTier {
    if (totalPurchases >= 50000) return 'Gold';
    if (totalPurchases >= 20000) return 'Silver';
    return 'Regular';
  }

  factory CustomerModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return CustomerModel(
      id:             docId,
      name:           data['name']           ?? '',
      phone:          data['phone'],
      email:          data['email'],
      address:        data['address'],
      totalPurchases: (data['totalPurchases'] ?? 0).toDouble(),
      visitCount:     (data['visitCount']     ?? 0) as int,
      loyaltyPoints:  (data['loyaltyPoints']  ?? 0).toDouble(),
      createdAt:      data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastVisit:      data['lastVisit'] != null
          ? (data['lastVisit'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name':           name,
    'phone':          phone,
    'email':          email,
    'address':        address,
    'totalPurchases': totalPurchases,
    'visitCount':     visitCount,
    'loyaltyPoints':  loyaltyPoints,
    'createdAt':      FieldValue.serverTimestamp(),
    'lastVisit':      lastVisit != null ? Timestamp.fromDate(lastVisit!) : null,
  };

  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    double? totalPurchases,
    int?    visitCount,
    double? loyaltyPoints,
    DateTime? createdAt,
    DateTime? lastVisit,
  }) =>
      CustomerModel(
        id:             id             ?? this.id,
        name:           name           ?? this.name,
        phone:          phone          ?? this.phone,
        email:          email          ?? this.email,
        address:        address        ?? this.address,
        totalPurchases: totalPurchases ?? this.totalPurchases,
        visitCount:     visitCount     ?? this.visitCount,
        loyaltyPoints:  loyaltyPoints  ?? this.loyaltyPoints,
        createdAt:      createdAt      ?? this.createdAt,
        lastVisit:      lastVisit      ?? this.lastVisit,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CustomerModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
