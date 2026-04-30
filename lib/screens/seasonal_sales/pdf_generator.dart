/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:aboomar/app_localizations.dart';
import 'package:aboomar/models/seasonal_sales_model.dart';

class SeasonalSalesPdfGenerator {
  static Future<void> generate({
    required BuildContext context,
    required List<SeasonalSalesData> salesData,
    required DateTime date,
    required String categoryName,
  }) async {
    try {
      final regularFont = await PdfGoogleFonts.cairoRegular();
      final boldFont = await PdfGoogleFonts.cairoBold();

      final l = AppLocalizations.of(context)!;
      final formatter = NumberFormat("#,##0.00", "en_US");
      final isRTL = Localizations.localeOf(context).languageCode == 'ar';

      // حساب الإجماليات
      final double totalQuantity = salesData.fold(0, (sum, item) => sum + item.quantity);
      final double totalSales = salesData.fold(0, (sum, item) => sum + item.totalCost);
      final double totalBalance = salesData.fold(0, (sum, item) => sum + item.balance);

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          header: (pw.Context context) => _buildHeader(l, date, categoryName, boldFont, regularFont, isRTL),
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                '${l.translate("page")} ${context.pageNumber} ${l.translate("of")} ${context.pagesCount}',
                style: pw.TextStyle(font: regularFont, fontSize: 8),
              ),
            );
          },
          build: (pw.Context context) => [
            _buildTable(l, salesData, boldFont, regularFont, formatter),
            pw.SizedBox(height: 20),
            _buildGrandTotal(l, totalQuantity, totalSales, totalBalance, boldFont, regularFont, formatter, isRTL),
          ],
        ),
      );

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF Generation Error: $e')),
      );
    }
  }

  static pw.Widget _buildHeader(AppLocalizations l, DateTime date, String categoryName, pw.Font boldFont, pw.Font regularFont, bool isRTL) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: isRTL ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            l.translate("seasonal_sales_report"),
            style: pw.TextStyle(font: boldFont, fontSize: 20, color: PdfColor.fromHex('#3F51B5')),
            textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            '${l.translate("date")}: ${DateFormat('dd-MM-yyyy').format(date)}',
            style: pw.TextStyle(font: regularFont, fontSize: 12),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            '${l.translate("category")}: $categoryName',
            style: pw.TextStyle(font: regularFont, fontSize: 12),
            textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          ),
          pw.Divider(height: 15, thickness: 1),
        ],
      ),
    );
  }

  static pw.Table _buildTable(AppLocalizations l, List<SeasonalSalesData> salesData, pw.Font boldFont, pw.Font regularFont, NumberFormat formatter) {
    final headers = [
      l.translate("serial_short"),
      l.translate("branch"),
      l.translate("quantity"),
      l.translate("total_sales"),
      l.translate("balance"),
    ];
    return pw.Table.fromTextArray(
      headers: headers,
      data: salesData.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        return [
          (index + 1).toString(),
          data.branchName,
          formatter.format(data.quantity),
          formatter.format(data.totalCost),
          formatter.format(data.balance),
        ];
      }).toList(),
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
      headerStyle: pw.TextStyle(font: boldFont, fontSize: 10, color: PdfColors.white),
      headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#3F51B5')),
      cellStyle: pw.TextStyle(font: regularFont, fontSize: 9),
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.center,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildGrandTotal(AppLocalizations l, double qty, double sales, double balance, pw.Font boldFont, pw.Font regularFont, NumberFormat formatter, bool isRTL) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F4F7FC'),
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: isRTL ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            l.translate("grand_total"),
            style: pw.TextStyle(font: boldFont, fontSize: 14),
            textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          ),
          pw.Divider(height: 10),
          _buildTotalRowPdf(l.translate("total_quantity"), formatter.format(qty), regularFont, boldFont, isRTL),
          _buildTotalRowPdf(l.translate("total_sales"), formatter.format(sales), regularFont, boldFont, isRTL),
          _buildTotalRowPdf(l.translate("total_balance"), formatter.format(balance), regularFont, boldFont, isRTL),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalRowPdf(String label, String value, pw.Font regularFont, pw.Font boldFont, bool isRTL) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: regularFont, fontSize: 10), textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr),
          pw.Text(value, style: pw.TextStyle(font: boldFont, fontSize: 11)),
        ],
      ),
    );
  }
}

 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:aboomar2release/app_localizations.dart';
import 'package:aboomar2release/models/seasonal_sales_model.dart';

class SeasonalSalesPdfGenerator {
  static Future<void> generate({
    required BuildContext context,
    required List<SeasonalSalesData> salesData,
    required DateTime date,
    required String categoryName,
  }) async {
    try {
      final regularFont = await PdfGoogleFonts.cairoRegular();
      final boldFont = await PdfGoogleFonts.cairoBold();

      final l = AppLocalizations.of(context)!;
      final formatter = NumberFormat("#,##0.00", "en_US");
      final isRTL = Localizations.localeOf(context).languageCode == 'ar';

      // -- Start of Changes --
      // 3. إضافة وقت وتاريخ الطباعة الفعلي
      final printDateTime = DateTime.now();

      // حساب الإجماليات
      final double totalQuantity = salesData.fold(0, (sum, item) => sum + item.quantity);
      final double totalSales = salesData.fold(0, (sum, item) => sum + item.totalCost);
      final double totalBalance = salesData.fold(0, (sum, item) => sum + item.balance);

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          // 3. تمرير وقت الطباعة إلى الهيدر
          header: (pw.Context context) => _buildHeader(l, date, categoryName, boldFont, regularFont, isRTL, printDateTime),
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                '${l.translate("page")} ${context.pageNumber} ${l.translate("of")} ${context.pagesCount}',
                // 1. تكبير الخط
                style: pw.TextStyle(font: regularFont, fontSize: 12),
              ),
            );
          },
          build: (pw.Context context) => [
            _buildTable(l, salesData, boldFont, regularFont, formatter),
            pw.SizedBox(height: 20),
            _buildGrandTotal(l, totalQuantity, totalSales, totalBalance, boldFont, regularFont, formatter, isRTL),
          ],
        ),
      );
      // -- End of Changes --

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF Generation Error: $e')),
      );
    }
  }

  // 3. تعديل الدالة لاستقبال وقت الطباعة
  static pw.Widget _buildHeader(AppLocalizations l, DateTime date, String categoryName, pw.Font boldFont, pw.Font regularFont, bool isRTL, DateTime printDateTime) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: isRTL ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            l.translate("seasonal_sales_report"),
            // 1. تكبير الخط
            style: pw.TextStyle(font: boldFont, fontSize: 25, color: PdfColor.fromHex('#3F51B5')),
            textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '${l.translate("date")}: ${DateFormat('dd-MM-yyyy').format(date)}',
            // 1. تكبير الخط
            style: pw.TextStyle(font: regularFont, fontSize: 16),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            '${l.translate("category")}: $categoryName',
            // 1. تكبير الخط
            style: pw.TextStyle(font: regularFont, fontSize: 16),
            textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          ),
          pw.SizedBox(height: 5),
          // 3. عرض وقت وتاريخ الطباعة
          pw.Text(
            '${l.translate("print_date")}: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(printDateTime)}',
            style: pw.TextStyle(font: regularFont, fontSize: 14, color: PdfColors.grey700),
          ),
          pw.Divider(height: 15, thickness: 1),
        ],
      ),
    );
  }

  static pw.Table _buildTable(AppLocalizations l, List<SeasonalSalesData> salesData, pw.Font boldFont, pw.Font regularFont, NumberFormat formatter) {
    final headers = [
      l.translate("serial_short"),
      l.translate("branch"),
      l.translate("quantity"),
      l.translate("total_sales"),
      l.translate("balance"),
    ];
    return pw.Table.fromTextArray(
      headers: headers,
      data: salesData.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        return [
          (index + 1).toString(),
          data.branchName,
          formatter.format(data.quantity),
          formatter.format(data.totalCost),
          formatter.format(data.balance),
        ];
      }).toList(),
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
      // 1. تكبير الخط
      headerStyle: pw.TextStyle(font: boldFont, fontSize: 15, color: PdfColors.white),
      headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#3F51B5')),
      // 1. تكبير الخط
      cellStyle: pw.TextStyle(font: regularFont, fontSize: 13),
      // 2. توسيط جميع الأعمدة
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
      },
    );
  }

  static pw.Widget _buildGrandTotal(AppLocalizations l, double qty, double sales, double balance, pw.Font boldFont, pw.Font regularFont, NumberFormat formatter, bool isRTL) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F4F7FC'),
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: isRTL ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            l.translate("grand_total"),
            // 1. تكبير الخط
            style: pw.TextStyle(font: boldFont, fontSize: 18),
            textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          ),
          pw.Divider(height: 10),
          _buildTotalRowPdf(l.translate("total_quantity"), formatter.format(qty), regularFont, boldFont, isRTL),
          _buildTotalRowPdf(l.translate("total_sales"), formatter.format(sales), regularFont, boldFont, isRTL),
          _buildTotalRowPdf(l.translate("total_balance"), formatter.format(balance), regularFont, boldFont, isRTL),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalRowPdf(String label, String value, pw.Font regularFont, pw.Font boldFont, bool isRTL) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // 1. تكبير الخط
          pw.Text(label, style: pw.TextStyle(font: regularFont, fontSize: 14), textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr),
          // 1. تكبير الخط
          pw.Text(value, style: pw.TextStyle(font: boldFont, fontSize: 15)),
        ],
      ),
    );
  }
}