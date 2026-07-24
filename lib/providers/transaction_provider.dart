import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../services/app_data.dart';
import '../services/hive_services.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> get transactions => AppData.transactions;

  double get totalIncome {
    double total = 0;

    for (final transaction in transactions) {
      if (transaction.type == "Income") {
        total += transaction.amount;
      }
    }

    return total;
  }

  double get totalExpense {
    double total = 0;

    for (final transaction in transactions) {
      if (transaction.type == "Expense") {
        total += transaction.amount;
      }
    }

    return total;
  }

  double get balance {
    return totalIncome - totalExpense;
  }

  void loadTransactions() {
    AppData.loadTransactions();
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await HiveService.addTransaction({
      'id': transaction.id,
      'type': transaction.type,
      'category': transaction.category,
      'amount': transaction.amount,
      'description': transaction.description,
      'date': transaction.date.toIso8601String(),
    });

    AppData.loadTransactions();

    notifyListeners();
  }

  Future<void> deleteTransaction(int index) async {
    await HiveService.deleteTransaction(index);

    AppData.loadTransactions();

    notifyListeners();
  }

  Future<void> updateTransaction(
    int index,
    TransactionModel transaction,
  ) async {
    await HiveService.updateTransaction(index, {
      'id': transaction.id,
      'type': transaction.type,
      'category': transaction.category,
      'amount': transaction.amount,
      'description': transaction.description,
      'date': transaction.date.toIso8601String(),
    });

    AppData.loadTransactions();

    notifyListeners();
  }

  Map<String, double> get categoryExpenses {
    final Map<String, double> data = {};

    for (final transaction in transactions) {
      if (transaction.type == "Expense") {
        data[transaction.category] =
            (data[transaction.category] ?? 0) + transaction.amount;
      }
    }

    return data;
  }
}
