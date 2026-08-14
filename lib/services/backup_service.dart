import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/transaction_model.dart';
import 'app_data.dart';

class BackupService {
  // ============================================================
  // CREATE BACKUP
  // ============================================================

  static Future<bool> backupData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final file = File("${directory.path}/expense_tracker_backup.json");

      final data = AppData.transactions
          .map((transaction) => transaction.toJson())
          .toList();

      final jsonString = const JsonEncoder.withIndent("  ").convert(data);

      await file.writeAsString(jsonString);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: "Expense Tracker Backup");

      return true;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // RESTORE BACKUP
  // ============================================================

  static Future<bool> restoreData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) {
        return false;
      }

      final filePath = result.files.single.path;

      if (filePath == null) {
        return false;
      }

      final file = File(filePath);

      final jsonString = await file.readAsString();

      final decodedData = jsonDecode(jsonString);

      if (decodedData is! List) {
        return false;
      }

      final List<TransactionModel> transactions = [];

      for (final item in decodedData) {
        if (item is Map<String, dynamic>) {
          transactions.add(TransactionModel.fromJson(item));
        } else if (item is Map) {
          transactions.add(
            TransactionModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }

      if (transactions.isEmpty) {
        return false;
      }

      await AppData.saveTransactions(transactions);

      return true;
    } catch (e) {
      return false;
    }
  }
}
