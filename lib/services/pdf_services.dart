import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../services/app_data.dart';
import '../services/auth_service.dart';

class PdfService {
  static Future<bool> generatePdf({String currency = "Rs."}) async {
    try {
      final pdf = pw.Document();

      final currentUser = AuthService.getCurrentUser();

      double totalIncome = 0;
      double totalExpense = 0;

      for (final transaction in AppData.transactions) {
        if (transaction.type == "Income") {
          totalIncome += transaction.amount;
        } else if (transaction.type == "Expense") {
          totalExpense += transaction.amount;
        }
      }

      final balance = totalIncome - totalExpense;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(30),

          header: (context) {
            return pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Expense Tracker Pro",
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    "Financial Report",
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          },

          footer: (context) {
            return pw.Container(
              padding: const pw.EdgeInsets.only(top: 10),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Expense Tracker Pro",
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    "Page ${context.pageNumber}",
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            );
          },

          build: (context) => [
            pw.SizedBox(height: 15),

            // ============================
            // USER INFORMATION
            // ============================
            if (currentUser != null)
              pw.Text(
                "User: ${currentUser.name}",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

            if (currentUser != null) pw.SizedBox(height: 5),

            pw.Text(
              "Generated: ${DateTime.now().toString().split('.')[0]}",
              style: const pw.TextStyle(fontSize: 10),
            ),

            pw.SizedBox(height: 25),

            // ============================
            // SUMMARY
            // ============================
            pw.Text(
              "Financial Summary",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 12),

            pw.Row(
              children: [
                _summaryBox(
                  "Total Income",
                  "$currency ${totalIncome.toStringAsFixed(0)}",
                ),

                pw.SizedBox(width: 10),

                _summaryBox(
                  "Total Expense",
                  "$currency ${totalExpense.toStringAsFixed(0)}",
                ),

                pw.SizedBox(width: 10),

                _summaryBox(
                  "Balance",
                  "$currency ${balance.toStringAsFixed(0)}",
                ),
              ],
            ),

            pw.SizedBox(height: 30),

            // ============================
            // TRANSACTIONS
            // ============================
            pw.Text(
              "Transactions",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 12),

            AppData.transactions.isEmpty
                ? pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    child: pw.Center(
                      child: pw.Text("No transactions available."),
                    ),
                  )
                : pw.TableHelper.fromTextArray(
                    border: pw.TableBorder.all(color: PdfColors.grey300),

                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                    ),

                    cellStyle: const pw.TextStyle(fontSize: 8),

                    headerDecoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),

                    cellPadding: const pw.EdgeInsets.all(6),

                    headers: const [
                      "Date",
                      "Category",
                      "Type",
                      "Amount",
                      "Description",
                    ],

                    data: AppData.transactions.map((t) {
                      return [
                        "${t.date.day.toString().padLeft(2, '0')}/"
                            "${t.date.month.toString().padLeft(2, '0')}/"
                            "${t.date.year}",

                        t.category,

                        t.type,

                        "$currency ${t.amount.toStringAsFixed(0)}",

                        t.description,
                      ];
                    }).toList(),
                  ),

            pw.SizedBox(height: 25),

            // ============================
            // FINAL BALANCE
            // ============================
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Final Balance",
                    style: pw.TextStyle(
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),

                  pw.Text(
                    "$currency ${balance.toStringAsFixed(0)}",
                    style: pw.TextStyle(
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      final Uint8List bytes = await pdf.save();

      await Printing.layoutPdf(onLayout: (format) async => bytes);

      return true;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // SUMMARY BOX
  // ============================================================

  static pw.Widget _summaryBox(String title, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: const pw.TextStyle(fontSize: 9)),

            pw.SizedBox(height: 5),

            pw.Text(
              value,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
