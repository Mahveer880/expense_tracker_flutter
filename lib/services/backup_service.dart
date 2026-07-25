import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
}
