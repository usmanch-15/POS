import 'package:cloud_firestore/cloud_firestore.dart';

enum ExpenseCategory {
  rent,
  utilities,
  salaries,
  transport,
  marketing,
  maintenance,
  supplies,
  other,
}

extension ExpenseCategoryExt on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.rent:        return 'Rent';
      case ExpenseCategory.utilities:   return 'Utilities';
      case ExpenseCategory.salaries:    return 'Salaries';
      case ExpenseCategory.transport:   return 'Transport';
      case ExpenseCategory.marketing:   return 'Marketing';
      case ExpenseCategory.maintenance: return 'Maintenance';
      case ExpenseCategory.supplies:    return 'Supplies';
      case ExpenseCategory.other:       return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case ExpenseCategory.rent:        return '🏠';
      case ExpenseCategory.utilities:   return '⚡';
      case ExpenseCategory.salaries:    return '👤';
      case ExpenseCategory.transport:   return '🚗';
      case ExpenseCategory.marketing:   return '📢';
      case ExpenseCategory.maintenance: return '🔧';
      case ExpenseCategory.supplies:    return '📦';
      case ExpenseCategory.other:       return '💸';
    }
  }
}

class ExpenseModel {
  final String          id;
  final String          title;
  final double          amount;
  final ExpenseCategory category;
  final String?         description;
  final String?         paidTo;
  final String?         addedBy;   // ✅ createdBy ki jagah addedBy use hota hai
  final DateTime        date;
  final DateTime        createdAt;

  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    this.description,
    this.paidTo,
    this.addedBy,
    required this.date,
    required this.createdAt, // ✅ FIX: createdBy parameter hataya
  });

  static ExpenseCategory _categoryFrom(String? s) {
    return ExpenseCategory.values.firstWhere(
          (e) => e.name == s,
      orElse: () => ExpenseCategory.other,
    );
  }

  factory ExpenseModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return ExpenseModel(
      id:          docId,
      title:       data['title']   ?? '',
      amount:      (data['amount'] ?? 0).toDouble(),
      category:    _categoryFrom(data['category']),
      description: data['description'],
      paidTo:      data['paidTo'],
      addedBy:     data['addedBy'],
      date:        data['date'] != null
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
      createdAt:   data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      // ✅ FIX: createdBy nahi diya — field exist nahi karti
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title':       title,
    'amount':      amount,
    'category':    category.name,
    'description': description,
    'paidTo':      paidTo,
    'addedBy':     addedBy,
    'date':        Timestamp.fromDate(date),
    'createdAt':   FieldValue.serverTimestamp(),
  };

  ExpenseModel copyWith({
    String?          id,
    String?          title,
    double?          amount,
    ExpenseCategory? category,
    String?          description,
    String?          paidTo,
    String?          addedBy,
    DateTime?        date,
    DateTime?        createdAt,
  }) =>
      ExpenseModel(
        id:          id          ?? this.id,
        title:       title       ?? this.title,
        amount:      amount      ?? this.amount,
        category:    category    ?? this.category,
        description: description ?? this.description,
        paidTo:      paidTo      ?? this.paidTo,
        addedBy:     addedBy     ?? this.addedBy,
        date:        date        ?? this.date,
        createdAt:   createdAt   ?? this.createdAt,
        // ✅ FIX: createdBy copyWith mein bhi nahi
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ExpenseModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}