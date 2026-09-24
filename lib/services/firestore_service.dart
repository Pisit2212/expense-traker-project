import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class FirestoreService {
  final String uid;
  FirestoreService(this.uid);

  CollectionReference<Map<String, dynamic>> get _col => FirebaseFirestore
      .instance
      .collection('users')
      .doc(uid)
      .collection('transactions');

  Stream<List<TransactionModel>> watchAll() => _col
      .orderBy('date', descending: true)
      .snapshots()
      .map((s) => s.docs.map(TransactionModel.fromDoc).toList());

  Future<void> add(TransactionModel t) => _col.add(t.toMap());

  Future<void> update(TransactionModel t) => _col.doc(t.id).update(t.toMap());

  Future<void> delete(String id) => _col.doc(id).delete();
}