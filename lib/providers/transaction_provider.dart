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

  List<TransactionModel> get monthItems => _all
      .where((t) => t.date.year == _month.year && t.date.month == _month.month)
      .toList();

  double get income => monthItems
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get expense => monthItems
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => income - expense;

  /// ยอดรวมแยกตามหมวดหมู่ของเดือนที่เลือก เรียงจากมากไปน้อย
  Map<String, double> categoryTotals({required bool income}) {
    final map = <String, double>{};
    for (final t in monthItems.where((t) => t.isIncome == income)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }

  /// ยอดรายรับ-รายจ่ายย้อนหลัง n เดือน (สิ้นสุดที่เดือนที่เลือก)
  List<MonthTotal> lastMonths(int n) {
    return List.generate(n, (i) {
      final m = DateTime(_month.year, _month.month - (n - 1 - i));
      final items = _all.where(
          (t) => t.date.year == m.year && t.date.month == m.month);
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