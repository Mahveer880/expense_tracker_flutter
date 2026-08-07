import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction_model.dart';
import 'package:file_picker/file_picker.dart';

import 'app_data.dart';

class BackupService {
  static Future<void> backupData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final file = File("${directory.path}/expense_tracker_backup.json");

      final data = AppData.transactions.map((e) => e.toJson()).toList();

      await file.writeAsString(
        const JsonEncoder.withIndent("  ").convert(data),
      );

      await Share.shareXFiles([
        XFile(file.path),
      ], text: "Expense Tracker Backup");
    } catch (e) {
      print(e);
    }
  }

  static Future<void> restoreData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);

      final jsonString = await file.readAsString();

      final List<dynamic> jsonData = jsonDecode(jsonString);

      final transactions = jsonData
          .map((e) => TransactionModel.fromJson(e))
          .toList();

      await AppData.saveTransactions(transactions);
    } catch (e) {
      print(e);
    }
  }
}
