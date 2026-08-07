import 'package:hive_flutter/hive_flutter.dart';

import 'auth_service.dart';

class HiveService {
  static final Box transactionBox = Hive.box('transactions');

  static Future<void> addTransaction(Map<String, dynamic> transaction) async {
    final currentUser = AuthService.getCurrentUser();

    if (currentUser == null) return;

    transaction['userId'] = currentUser.id;

    await transactionBox.add(transaction);
  }

  static List<Map<String, dynamic>> getTransactions() {
    final currentUser = AuthService.getCurrentUser();

    if (currentUser == null) return [];

    return transactionBox.values
        .map((e) => Map<String, dynamic>.from(e))
        .where((item) => item['userId'] == currentUser.id)
        .toList();
  }

  static Future<void> deleteTransaction(int index) async {
    final currentUser = AuthService.getCurrentUser();

    if (currentUser == null) return;

    final keys = transactionBox.keys.toList();

    int count = -1;

    for (final key in keys) {
      final item = Map<String, dynamic>.from(transactionBox.get(key));

      if (item['userId'] == currentUser.id) {
        count++;

        if (count == index) {
          await transactionBox.delete(key);
          break;
        }
      }
    }
  }

  static Future<void> updateTransaction(
    int index,
    Map<String, dynamic> transaction,
  ) async {
    final currentUser = AuthService.getCurrentUser();

    if (currentUser == null) return;

    transaction['userId'] = currentUser.id;

    final keys = transactionBox.keys.toList();

    int count = -1;

    for (final key in keys) {
      final item = Map<String, dynamic>.from(transactionBox.get(key));

      if (item['userId'] == currentUser.id) {
        count++;

        if (count == index) {
          await transactionBox.put(key, transaction);
          break;
        }
      }
    }
  }

  static Future<void> clearTransactions() async {
    final currentUser = AuthService.getCurrentUser();

    if (currentUser == null) return;

    final keys = transactionBox.keys.toList();

    for (final key in keys) {
      final item = Map<String, dynamic>.from(transactionBox.get(key));

      if (item['userId'] == currentUser.id) {
        await transactionBox.delete(key);
      }
    }
  }
}
