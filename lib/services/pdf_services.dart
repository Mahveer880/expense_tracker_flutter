import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../services/app_data.dart';

class PdfService {
  static Future<void> generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              "Expense Tracker Pro",
              style: pw.TextStyle(fontSize: 24),
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Table.fromTextArray(
            headers: ["Date", "Category", "Type", "Amount", "Description"],
            data: AppData.transactions.map((t) {
              return [
                t.date.toString().split(" ")[0],
                t.category,
                t.type,
                t.amount.toString(),
                t.description,
              ];
            }).toList(),
          ),
        ],
      ),
    );

    Uint8List bytes = await pdf.save();

    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }
}
