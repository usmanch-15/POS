// lib/services/expense_service.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Expense Firestore Service
// ─────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';

class ExpenseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference get _col => _db.collection('expenses');

  // ── Stream all expenses ────────────────────────────────────
  Stream<List<ExpenseModel>> streamExpenses({int limit = 50}) {
    return _col
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ExpenseModel.fromFirestore(
                  d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  // ── Get in date range ──────────────────────────────────────
  Future<List<ExpenseModel>> getExpensesInRange(
      DateTime from, DateTime to) async {
    final snap = await _col
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('date', isLessThanOrEqualTo:    Timestamp.fromDate(to))
        .orderBy('date', descending: true)
        .get();
    return snap.docs
        .map((d) => ExpenseModel.fromFirestore(
              d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  // ── Total for a month ──────────────────────────────────────
  Future<double> getMonthTotal(int month, int year) async {
    final from = DateTime(year, month, 1);
    final to   = DateTime(year, month + 1, 0, 23, 59, 59);
    final list = await getExpensesInRange(from, to);
    return list.fold<double>(0.0, (s, e) => s + e.amount);
  }

  // ── Add ────────────────────────────────────────────────────
  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    final ref = await _col.add(expense.toFirestore());
    return expense.copyWith(id: ref.id);
  }

  // ── Update ─────────────────────────────────────────────────
  Future<void> updateExpense(ExpenseModel expense) =>
      _col.doc(expense.id).update(expense.toFirestore());

  // ── Delete ─────────────────────────────────────────────────
  Future<void> deleteExpense(String id) => _col.doc(id).delete();
}
