import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'dart:html' if (dart.library.html) 'dart:html' as html;
import '../models/expense.dart';

/// Service for exporting expenses to PDF and sharing
class ExportService {
  /// Generate PDF with all expenses
  static Future<Uint8List> generateExpensePDF(List<Expense> expenses) async {
    final pdf = pw.Document();
    final formatter = DateFormat('dd MMM yyyy');
    final currencyFormatter = NumberFormat('#,##0.00');

    // Group expenses by category
    final categoryTotals = <ExpenseCategory, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    final totalExpense = expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // Header
          pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF6750A4),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            padding: pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Expense Tracker Report',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Generated on ${formatter.format(DateTime.now())}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.white,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Summary Cards
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFE8DFF5),
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(
                      color: PdfColor.fromInt(0xFF6750A4),
                      width: 2,
                    ),
                  ),
                  padding: pw.EdgeInsets.all(16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Total Expenses',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColor.fromInt(0xFF49454E),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Rs.${currencyFormatter.format(totalExpense)}',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF6750A4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFE8F5E9),
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(
                      color: PdfColor.fromInt(0xFF2E7D32),
                      width: 2,
                    ),
                  ),
                  padding: pw.EdgeInsets.all(16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Total Entries',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColor.fromInt(0xFF49454E),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        '${expenses.length}',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // Category Breakdown
          pw.Text(
            'Category Breakdown',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromInt(0xFF1F1F1F),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColor.fromInt(0xFFCAC4D0),
              width: 1,
            ),
            children: [
              // Header Row
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFEADDFF),
                ),
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Category',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Amount',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Percentage',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
              // Data Rows
              ...ExpenseCategory.values.map((category) {
                final amount = categoryTotals[category] ?? 0;
                final percentage = totalExpense > 0
                    ? ((amount / totalExpense) * 100)
                    : 0;
                final color = PdfColor.fromInt(category.colorValue);

                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFEADDFF),
                  ),
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        category.displayName,
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Rs.${currencyFormatter.format(amount)}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: color,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
          pw.SizedBox(height: 20),

          // Detailed Expenses
          pw.Text(
            'Detailed Expenses',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromInt(0xFF1F1F1F),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColor.fromInt(0xFFCAC4D0),
              width: 1,
            ),
            children: [
              // Header
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFEADDFF),
                ),
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Date',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Title',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Category',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Amount',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
              // Data Rows
              ...expenses.map((expense) {
                final color = PdfColor.fromInt(expense.category.colorValue);
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF5F5F5),
                  ),
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        formatter.format(expense.date),
                        style: pw.TextStyle(fontSize: 9),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        expense.title,
                        style: pw.TextStyle(fontSize: 9),
                        maxLines: 1,
                        overflow: pw.TextOverflow.clip,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        expense.category.displayName,
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: color,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Rs.${currencyFormatter.format(expense.amount)}',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: color,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
          pw.SizedBox(height: 20),

          // Footer
          pw.Divider(color: PdfColor.fromInt(0xFFCAC4D0)),
          pw.SizedBox(height: 10),
          pw.Text(
            'This report was generated by Expense Tracker',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColor.fromInt(0xFF79747E),
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );

    // Save PDF
    final pdfBytes = await pdf.save();

    if (kIsWeb) {
      // For web, just return the bytes (will be handled by caller)
      return pdfBytes;
    } else {
      // For mobile, save to file and return the bytes
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/Expense_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(pdfBytes);
      return pdfBytes;
    }
  }

  /// Generate TXT file with expenses
  static Future<File> generateExpenseTXT(List<Expense> expenses) async {
    final buffer = StringBuffer();
    final formatter = DateFormat('dd MMM yyyy');
    final currencyFormatter = NumberFormat('#,##0.00');

    buffer.writeln('═' * 60);
    buffer.writeln('EXPENSE TRACKER - DETAILED REPORT');
    buffer.writeln('═' * 60);
    buffer.writeln('Generated on: ${formatter.format(DateTime.now())}');
    buffer.writeln('');

    // Summary
    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    buffer.writeln('SUMMARY');
    buffer.writeln('─' * 60);
    buffer.writeln('Total Expenses: Rs.${currencyFormatter.format(total)}');
    buffer.writeln('Total Entries: ${expenses.length}');
    buffer.writeln('');

    // Category breakdown
    buffer.writeln('CATEGORY BREAKDOWN');
    buffer.writeln('─' * 60);
    final categoryTotals = <ExpenseCategory, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    for (final category in ExpenseCategory.values) {
      final amount = categoryTotals[category] ?? 0;
      if (amount > 0) {
        final percentage = (amount / total) * 100;
        buffer.writeln(
          '${category.displayName.padRight(15)} : Rs.${currencyFormatter.format(amount).padLeft(12)} (${percentage.toStringAsFixed(1)}%)',
        );
      }
    }
    buffer.writeln('');

    // Detailed expenses
    buffer.writeln('DETAILED EXPENSES');
    buffer.writeln('─' * 60);
    buffer.writeln(
      'Date'.padRight(15) +
          'Title'.padRight(20) +
          'Category'.padRight(15) +
          'Amount'.padRight(15),
    );
    buffer.writeln('─' * 60);

    for (final expense in expenses) {
      buffer.writeln(
        formatter.format(expense.date).padRight(15) +
            expense.title
                .substring(
                  0,
                  (expense.title.length > 19 ? 19 : expense.title.length),
                )
                .padRight(20) +
            expense.category.displayName.padRight(15) +
            'Rs.${currencyFormatter.format(expense.amount).padLeft(12)}',
      );
    }

    buffer.writeln('═' * 60);

    // Save file (only on mobile)
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/Expense_Report_${DateTime.now().millisecondsSinceEpoch}.txt',
      );
      await file.writeAsString(buffer.toString());
      return file;
    }

    // For web, create a temporary file-like object (won't actually be used)
    throw UnsupportedError('File saving not supported on web');
  }

  /// Share expenses as TXT
  static Future<void> shareExpenses(List<Expense> expenses) async {
    if (kIsWeb) {
      // For web, generate text and copy to clipboard / show share dialog
      final textContent = await _generateExpenseText(expenses);
      try {
        await html.window.navigator.clipboard!.writeText(textContent);
        print('Expense data copied to clipboard');
      } catch (e) {
        print('Failed to copy to clipboard: $e');
      }
    } else {
      // For mobile, share as file
      final file = await generateExpenseTXT(expenses);
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'My Expense Report',
        text: 'Check out my expense tracker report!',
      );

      if (result.status == ShareResultStatus.success) {
        print('Expenses shared successfully');
      }
    }
  }

  /// Download expenses as PDF
  static Future<void> downloadExpensePDF(List<Expense> expenses) async {
    final pdfBytes = await generateExpensePDF(expenses);

    if (kIsWeb) {
      // For web, trigger browser download
      final blob = html.Blob([pdfBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute(
          'download',
          'Expense_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
        )
        ..click();
      html.Url.revokeObjectUrl(url);
      print('PDF downloaded successfully');
    } else {
      // For mobile, file is already saved
      print('PDF saved to device');
    }
  }

  /// Generate expense text content
  static Future<String> _generateExpenseText(List<Expense> expenses) async {
    final buffer = StringBuffer();
    final formatter = DateFormat('dd MMM yyyy');
    final currencyFormatter = NumberFormat('#,##0.00');

    buffer.writeln('═' * 60);
    buffer.writeln('EXPENSE TRACKER - DETAILED REPORT');
    buffer.writeln('═' * 60);
    buffer.writeln('Generated on: ${formatter.format(DateTime.now())}');
    buffer.writeln('');

    // Summary
    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    buffer.writeln('SUMMARY');
    buffer.writeln('─' * 60);
    buffer.writeln('Total Expenses: Rs.${currencyFormatter.format(total)}');
    buffer.writeln('Total Entries: ${expenses.length}');
    buffer.writeln('');

    // Category breakdown
    buffer.writeln('CATEGORY BREAKDOWN');
    buffer.writeln('─' * 60);
    final categoryTotals = <ExpenseCategory, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    for (final category in ExpenseCategory.values) {
      final amount = categoryTotals[category] ?? 0;
      if (amount > 0) {
        final percentage = (amount / total) * 100;
        buffer.writeln(
          '${category.displayName.padRight(15)} : Rs.${currencyFormatter.format(amount).padLeft(12)} (${percentage.toStringAsFixed(1)}%)',
        );
      }
    }
    buffer.writeln('');

    // Detailed expenses
    buffer.writeln('DETAILED EXPENSES');
    buffer.writeln('─' * 60);
    buffer.writeln(
      'Date'.padRight(15) +
          'Title'.padRight(20) +
          'Category'.padRight(15) +
          'Amount'.padRight(15),
    );
    buffer.writeln('─' * 60);

    for (final expense in expenses) {
      final titleShort = expense.title.length > 19
          ? expense.title.substring(0, 19)
          : expense.title;
      buffer.writeln(
        formatter.format(expense.date).padRight(15) +
            titleShort.padRight(20) +
            expense.category.displayName.padRight(15) +
            'Rs.${currencyFormatter.format(expense.amount).padLeft(12)}',
      );
    }

    buffer.writeln('═' * 60);

    return buffer.toString();
  }
}
