import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../services/app_data.dart';
import '../services/hive_services.dart';

class TransactionProvider extends ChangeNotifier {
  // =====================================================
  // SEARCH & FILTER
  // =====================================================

  String _searchQuery = '';
  String _typeFilter = 'All';
  String _categoryFilter = 'All';

  String get searchQuery => _searchQuery;
  String get typeFilter => _typeFilter;
  String get categoryFilter => _categoryFilter;

  // =====================================================
  // ALL TRANSACTIONS
  // =====================================================

  List<TransactionModel> get transactions => AppData.transactions;

  // =====================================================
  // FILTERED TRANSACTIONS
  // =====================================================

  List<TransactionModel> get filteredTransactions {
    List<TransactionModel> result = List.from(transactions);

    // -------------------------
    // TYPE FILTER
    // -------------------------

    if (_typeFilter != 'All') {
      result = result
          .where((transaction) => transaction.type == _typeFilter)
          .toList();
    }

    // -------------------------
    // CATEGORY FILTER
    // -------------------------

    if (_categoryFilter != 'All') {
      result = result
          .where((transaction) => transaction.category == _categoryFilter)
          .toList();
    }

    // -------------------------
    // SEARCH
    // -------------------------

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();

      result = result.where((transaction) {
        return transaction.category.toLowerCase().contains(query) ||
            transaction.description.toLowerCase().contains(query) ||
            transaction.type.toLowerCase().contains(query) ||
            transaction.amount.toString().contains(query);
      }).toList();
    }

    return result;
  }

  // =====================================================
  // SET SEARCH
  // =====================================================

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // =====================================================
  // SET TYPE FILTER
  // =====================================================

  void setTypeFilter(String type) {
    _typeFilter = type;
    notifyListeners();
  }

  // =====================================================
  // SET CATEGORY FILTER
  // =====================================================

  void setCategoryFilter(String category) {
    _categoryFilter = category;
    notifyListeners();
  }

  // =====================================================
  // CLEAR SEARCH & FILTERS
  // =====================================================

  void clearFilters() {
    _searchQuery = '';
    _typeFilter = 'All';
    _categoryFilter = 'All';

    notifyListeners();
  }

  // =====================================================
  // TOTAL INCOME
  // =====================================================

  double get totalIncome {
    double total = 0;

    for (final transaction in transactions) {
      if (transaction.type == "Income") {
        total += transaction.amount;
      }
    }

    return total;
  }

  // =====================================================
  // TOTAL EXPENSE
  // =====================================================

  double get totalExpense {
    double total = 0;

    for (final transaction in transactions) {
      if (transaction.type == "Expense") {
        total += transaction.amount;
      }
    }

    return total;
  }

  // =====================================================
  // BALANCE
  // =====================================================

  double get balance {
    return totalIncome - totalExpense;
  }

  // =====================================================
  // CURRENT MONTH EXPENSE
  // =====================================================

  double get currentMonthExpense {
    final now = DateTime.now();

    double total = 0;

    for (final transaction in transactions) {
      if (transaction.type == "Expense" &&
          transaction.date.year == now.year &&
          transaction.date.month == now.month) {
        total += transaction.amount;
      }
    }

    return total;
  }

  // =====================================================
  // CURRENT MONTH INCOME
  // =====================================================

  double get currentMonthIncome {
    final now = DateTime.now();

    double total = 0;

    for (final transaction in transactions) {
      if (transaction.type == "Income" &&
          transaction.date.year == now.year &&
          transaction.date.month == now.month) {
        total += transaction.amount;
      }
    }

    return total;
  }

  // =====================================================
  // CURRENT YEAR EXPENSE
  // =====================================================

  double get currentYearExpense {
    final now = DateTime.now();

    double total = 0;

    for (final transaction in transactions) {
      if (transaction.type == "Expense" && transaction.date.year == now.year) {
        total += transaction.amount;
      }
    }

    return total;
  }

  // =====================================================
  // CURRENT YEAR INCOME
  // =====================================================

  double get currentYearIncome {
    final now = DateTime.now();

    double total = 0;

    for (final transaction in transactions) {
      if (transaction.type == "Income" && transaction.date.year == now.year) {
        total += transaction.amount;
      }
    }

    return total;
  }

  // =====================================================
  // LOAD TRANSACTIONS
  // =====================================================

  void loadTransactions() {
    AppData.loadTransactions();
    notifyListeners();
  }

  // =====================================================
  // ADD TRANSACTION
  // =====================================================

  Future<void> addTransaction(TransactionModel transaction) async {
    await HiveService.addTransaction({
      'id': transaction.id,
      'userId': transaction.userId,
      'type': transaction.type,
      'category': transaction.category,
      'amount': transaction.amount,
      'description': transaction.description,
      'date': transaction.date.toIso8601String(),
    });

    AppData.loadTransactions();

    notifyListeners();
  }

  // =====================================================
  // DELETE TRANSACTION
  // =====================================================

  Future<void> deleteTransaction(int index) async {
    await HiveService.deleteTransaction(index);

    AppData.loadTransactions();

    notifyListeners();
  }

  // =====================================================
  // UPDATE TRANSACTION
  // =====================================================

  Future<void> updateTransaction(
    int index,
    TransactionModel transaction,
  ) async {
    await HiveService.updateTransaction(index, {
      'id': transaction.id,
      'userId': transaction.userId,
      'type': transaction.type,
      'category': transaction.category,
      'amount': transaction.amount,
      'description': transaction.description,
      'date': transaction.date.toIso8601String(),
    });

    AppData.loadTransactions();

    notifyListeners();
  }

  // =====================================================
  // CATEGORY WISE EXPENSE
  // =====================================================

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

  // =====================================================
  // MONTHLY EXPENSE
  // =====================================================

  Map<String, double> get monthlyExpenses {
    final Map<String, double> data = {};

    for (final transaction in transactions) {
      if (transaction.type == "Expense") {
        final month = "${transaction.date.month}/${transaction.date.year}";

        data[month] = (data[month] ?? 0) + transaction.amount;
      }
    }

    return data;
  }

  // =====================================================
  // MONTHLY INCOME
  // =====================================================

  Map<String, double> get monthlyIncome {
    final Map<String, double> data = {};

    for (final transaction in transactions) {
      if (transaction.type == "Income") {
        final month = "${transaction.date.month}/${transaction.date.year}";

        data[month] = (data[month] ?? 0) + transaction.amount;
      }
    }

    return data;
  }

  // =====================================================
  // YEARLY EXPENSE
  // =====================================================

  Map<String, double> get yearlyExpenses {
    final Map<String, double> data = {};

    for (final transaction in transactions) {
      if (transaction.type == "Expense") {
        final year = transaction.date.year.toString();

        data[year] = (data[year] ?? 0) + transaction.amount;
      }
    }

    return data;
  }

  // =====================================================
  // YEARLY INCOME
  // =====================================================

  Map<String, double> get yearlyIncome {
    final Map<String, double> data = {};

    for (final transaction in transactions) {
      if (transaction.type == "Income") {
        final year = transaction.date.year.toString();

        data[year] = (data[year] ?? 0) + transaction.amount;
      }
    }

    return data;
  }
}
