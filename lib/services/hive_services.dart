import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static final Box transactionBox = Hive.box('transactions');

  static Future<void> addTransaction(Map<String, dynamic> transaction) async {
    await transactionBox.add(transaction);
  }

  static List<Map<String, dynamic>> getTransactions() {
    return transactionBox.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Future<void> deleteTransaction(int index) async {
    await transactionBox.deleteAt(index);
  }

  static Future<void> updateTransaction(
    int index,
    Map<String, dynamic> transaction,
  ) async {
    await transactionBox.putAt(index, transaction);
  }
}
