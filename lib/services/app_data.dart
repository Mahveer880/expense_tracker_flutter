import '../models/transaction_model.dart';
import 'hive_services.dart';

class AppData {
  static List<TransactionModel> transactions = [];

  static void loadTransactions() {
    final data = HiveService.getTransactions();

    transactions = data.map((item) {
      return TransactionModel(
        id: item['id'],
        type: item['type'],
        category: item['category'],
        amount: (item['amount'] as num).toDouble(),
        description: item['description'],
        date: DateTime.parse(item['date']),
      );
    }).toList();
  }

  static void refresh() {
    loadTransactions();
  }

  static Future<void> deleteTransaction(int index) async {
    await HiveService.deleteTransaction(index);
    loadTransactions();
  }
}
