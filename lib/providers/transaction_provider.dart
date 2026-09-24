import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../services/firestore_service.dart';

class MonthTotal {
  final DateTime month;
  final double income;
  final double expense;
  MonthTotal(this.month, this.income, this.expense);
}

class TransactionProvider extends ChangeNotifier {
  final FirestoreService _service;
  StreamSubscription<List<TransactionModel>>? _sub;

  List<TransactionModel> _all = [];
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  bool loading = true;
  String? error;

  String? _categoryFilter;
  String _query = '';

  TransactionProvider(String uid) : _service = FirestoreService(uid) {
    _sub = _service.watchAll().listen(
      (data) {
        _all = data;
        loading = false;
        error = null;
        notifyListeners();
      },
      onError: (e) {
        error = e.toString();
        loading = false;
        notifyListeners();
      },
    );
  }

  DateTime get month => _month;
  String? get categoryFilter => _categoryFilter;
  String get query => _query;

  List<TransactionModel> get monthItems => _all
      .where((t) => t.date.year == _month.year && t.date.month == _month.month)
      .toList();

  /// รายการที่แสดงใน list
  List<TransactionModel> get filteredItems {
    final q = _query.trim().toLowerCase();
    return monthItems.where((t) {
      final okCat = _categoryFilter == null || t.category == _categoryFilter;
      final okQuery = q.isEmpty ||
          t.note.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q);
      return okCat && okQuery;
    }).toList();
  }

  /// หมวดหมู่ที่มีในเดือนที่เลือก ไว้ทำปุ่มกรอง
  List<String> get monthCategories =>
      (monthItems.map((t) => t.category).toSet().toList()..sort());

  double get income => monthItems
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get expense => monthItems
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => income - expense;

  Map<String, double> categoryTotals({required bool income}) {
    final map = <String, double>{};
    for (final t in monthItems.where((t) => t.isIncome == income)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }

  List<MonthTotal> lastMonths(int n) {
    return List.generate(n, (i) {
      final m = DateTime(_month.year, _month.month - (n - 1 - i));
      final items =
          _all.where((t) => t.date.year == m.year && t.date.month == m.month);
      double inc = 0, exp = 0;
      for (final t in items) {
        if (t.isIncome) {
          inc += t.amount;
        } else {
          exp += t.amount;
        }
      }
      return MonthTotal(m, inc, exp);
    });
  }

  void changeMonth(int delta) {
    _month = DateTime(_month.year, _month.month + delta);
    _categoryFilter = null; 
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  Future<void> add(TransactionModel t) => _service.add(t);
  Future<void> update(TransactionModel t) => _service.update(t);
  Future<void> delete(String id) => _service.delete(id);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}