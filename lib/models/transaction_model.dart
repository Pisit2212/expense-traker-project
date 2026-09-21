import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String? id;
  final String type; // 'income' หรือ 'expense'
  final double amount;
  final String category;
  final String note;
  final DateTime date;

  TransactionModel({
    this.id,
    required this.type,
    required this.amount,
    required this.category,
    this.note = '',
    required this.date,
  });

  bool get isIncome => type == 'income';

  Map<String, dynamic> toMap() => {
        'type': type,
        'amount': amount,
        'category': category,
        'note': note,
        'date': Timestamp.fromDate(date),
      };

  factory TransactionModel.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return TransactionModel(
      id: doc.id,
      type: d['type'] ?? 'expense',
      amount: (d['amount'] as num).toDouble(),
      category: d['category'] ?? 'อื่นๆ',
      note: d['note'] ?? '',
      date: (d['date'] as Timestamp).toDate(),
    );
  }
}