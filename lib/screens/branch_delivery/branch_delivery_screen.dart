/*
import 'package:aboomar/main.dart';
import 'package:aboomar/services/api_exceptions.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../app_localizations.dart';
import '../../models/branch_delivery_model.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';
import 'widgets/delivery_data_table.dart';
import 'widgets/grand_total_card.dart';

class BranchDeliveryScreen extends StatefulWidget {
  final DateTime selectedDate;
  const BranchDeliveryScreen({super.key, required this.selectedDate});

  @override
  State<BranchDeliveryScreen> createState() => _BranchDeliveryScreenState();
}

class _BranchDeliveryScreenState extends State<BranchDeliveryScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  ApiException? _apiException;
  List<BranchDelivery>? _deliveries;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _apiException = null;
    });

    try {
      final deliveries = await _apiService.getBranchDeliveries(widget.selectedDate);
      setState(() {
        _deliveries = deliveries;
      });
    } on ApiException catch (e) {
      setState(() {
        _apiException = e;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.translate("branch_shifts_delivery")),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: (_deliveries != null && _deliveries!.isNotEmpty)
                ? () => _generatePDF(_deliveries!)
                : null,
          ),
          // ... other actions
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_apiException != null) {
      return _buildErrorWidget(context, _apiException!);
    }
    if (_deliveries == null || _deliveries!.isEmpty) {
      return Center(child: Text(l.translate("no_data_available")));
    }
    return Column(
      children: [
        Expanded(
          child: DeliveryDataTable(deliveries: _deliveries!),
        ),
        GrandTotalCard(
          totalCash: _deliveries!.fold(0, (sum, item) => sum + item.cashAmount),
          totalVisa: _deliveries!.fold(0, (sum, item) => sum + item.visaAmount),
          totalExpenses: _deliveries!.fold(0, (sum, item) => sum + item.expensesAmount),
          grandTotal: _deliveries!.fold(0, (sum, item) => sum + item.total),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(BuildContext context, ApiException error) {
    final localizations = AppLocalizations.of(context)!;
    final isNetworkError = error is NoInternetException;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isNetworkError ? Icons.wifi_off : Icons.cloud_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            localizations.translate(error.toString()),
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: Text(localizations.translate('retry')),
          ),
        ],
      ),
    );
  }

  // ... باقي الكود الخاص بـ _generatePDF والدوال المساعدة الأخرى يبقى كما هو ...
  Future<void> _generatePDF(List<BranchDelivery> deliveries) async {
    if (deliveries.isEmpty) {
      _showSnackBar('لا توجد بيانات لتصدير PDF');
      return;
    }

    final pdf = pw.Document();

    try {
      final regularFont = await PdfGoogleFonts.cairoRegular();
      final boldFont = await PdfGoogleFonts.cairoBold();

      final l = AppLocalizations.of(context)!;
      final formatter = NumberFormat("#,##0.00", "en_US");
      final currentLocale = Localizations.localeOf(context);
      final isRTL = currentLocale.languageCode == 'ar';
      final printDateTime = DateTime.now();

      final double totalCash = deliveries.fold(0, (sum, item) => sum + item.cashAmount);
      final double totalVisa = deliveries.fold(0, (sum, item) => sum + item.visaAmount);
      final double totalExpenses = deliveries.fold(0, (sum, item) => sum + item.expensesAmount);
      final double grandTotal = deliveries.fold(0, (sum, item) => sum + item.total);

      const int rowsPerPage = 18;
      final List<List<BranchDelivery>> pages = [];
      for (int i = 0; i < deliveries.length; i += rowsPerPage) {
        pages.add(deliveries.sublist(i, i + rowsPerPage > deliveries.length ? deliveries.length : i + rowsPerPage));
      }

      for (int pageIndex = 0; pageIndex < pages.length; pageIndex++) {
        final pageData = pages[pageIndex];

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(15),
            textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(10),
                    margin: const pw.EdgeInsets.only(bottom: 15),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#3F51B5'),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(l.translate("branch_shifts_delivery"), style: pw.TextStyle(font: boldFont, fontSize: 20, color: PdfColors.white), textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr),
                        pw.SizedBox(height: 5),
                        pw.Text('${l.translate("date")}: ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}', style: pw.TextStyle(font: regularFont, fontSize: 16, color: PdfColors.white)),
                        pw.SizedBox(height: 5),
                        pw.Text('${l.translate("print_date")}: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(printDateTime)}', style: pw.TextStyle(font: regularFont, fontSize: 14, color: PdfColors.grey)),
                      ],
                    ),
                  ),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),

                    // -- بداية التعديل --
                    // تم تعديل عرض الأعمدة لتناسب المحتوى الأكبر
                    columnWidths: {
                      0: const pw.FixedColumnWidth(40),      // المسلسل - زيادة العرض
                      1: const pw.FixedColumnWidth(50),      // التاريخ - زيادة العرض
                      2: const pw.FlexColumnWidth(2.2),    // الفرع
                      3: const pw.FlexColumnWidth(1.5),    // الكاش - زيادة العرض النسبي
                      4: const pw.FlexColumnWidth(1.5),    // الفيزا - زيادة العرض النسبي
                      5: const pw.FlexColumnWidth(1.5),    // المصروفات - زيادة العرض النسبي
                      6: const pw.FlexColumnWidth(1.6),    // الصافي - زيادة العرض النسبي
                    },
                    // -- نهاية التعديل --

                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColor.fromHex('#3F51B5')),
                        children: [
                          _buildCompactPdfCell(l.translate("serial"), boldFont, PdfColors.white, 12),
                          _buildCompactPdfCell(l.translate("date"), boldFont, PdfColors.white, 12),
                          _buildCompactPdfCell(l.translate("branch"), boldFont, PdfColors.white, 12),
                          _buildCompactPdfCell(l.translate("cash"), boldFont, PdfColors.white, 12),
                          _buildCompactPdfCell(l.translate("visa"), boldFont, PdfColors.white, 12),
                          _buildCompactPdfCell(l.translate("expenses"), boldFont, PdfColors.white, 12),
                          _buildCompactPdfCell(l.translate("total"), boldFont, PdfColors.white, 12),
                        ],
                      ),
                      ...pageData.asMap().entries.map((entry) {
                        final globalIndex = (pageIndex * rowsPerPage) + entry.key;
                        final delivery = entry.value;
                        final isEven = globalIndex % 2 == 0;
                        return pw.TableRow(
                          decoration: pw.BoxDecoration(color: isEven ? PdfColors.grey50 : PdfColors.white),
                          children: [
                            _buildCompactPdfCell((globalIndex + 1).toString(), regularFont, PdfColors.black, 11),
                            _buildCompactPdfCell(DateFormat('MM-dd').format(DateTime.parse(delivery.trnsDate)), regularFont, PdfColors.black, 11),
                            _buildCompactPdfCell(delivery.branchName, regularFont, PdfColors.black, 11, textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr),
                            _buildCompactPdfCell(formatter.format(delivery.cashAmount), regularFont, PdfColor.fromHex('#2E7D32'), 11),
                            _buildCompactPdfCell(formatter.format(delivery.visaAmount), regularFont, PdfColor.fromHex('#1565C0'), 11),
                            _buildCompactPdfCell(formatter.format(delivery.expensesAmount), regularFont, PdfColor.fromHex('#C62828'), 11),
                            _buildCompactPdfCell(formatter.format(delivery.total), boldFont, PdfColor.fromHex('#7B1FA2'), 11),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${l.translate("page")} ${pageIndex + 1} ${l.translate("of")} ${pages.length}',
                      style: pw.TextStyle(font: regularFont, fontSize: 14, color: PdfColors.grey),
                    ),
                  ),
                  if (pageIndex == pages.length - 1) ...[
                    pw.SizedBox(height: 20),
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#3F51B5'),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(l.translate("grand_total"), style: pw.TextStyle(font: boldFont, fontSize: 18, color: PdfColors.white), textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr),
                          pw.SizedBox(height: 5),
                          _buildTotalRowPdf(l.translate("total_cash"), formatter.format(totalCash), regularFont, isRTL),
                          _buildTotalRowPdf(l.translate("total_visa"), formatter.format(totalVisa), regularFont, isRTL),
                          _buildTotalRowPdf(l.translate("total_expenses"), formatter.format(totalExpenses), regularFont, isRTL),
                          pw.Divider(color: PdfColors.grey, height: 8),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(l.translate("total"), style: pw.TextStyle(font: boldFont, fontSize: 18, color: PdfColors.white), textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr),
                              pw.Text(formatter.format(grandTotal), style: pw.TextStyle(font: boldFont, fontSize: 18, color: PdfColors.white)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        );
      }

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
      _showSnackBar('تم إنشاء PDF بنجاح');

    } catch (e) {
      _showSnackBar('خطأ في إنشاء PDF: $e');
    }
  }

  pw.Widget _buildCompactPdfCell(
      String text,
      pw.Font font,
      PdfColor color,
      double fontSize, {
        pw.TextDirection? textDirection,
      }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: fontSize, color: color),
        textAlign: pw.TextAlign.center,
        textDirection: textDirection ?? (Localizations.localeOf(context).languageCode == 'ar' ? pw.TextDirection.rtl : pw.TextDirection.ltr),
        maxLines: 2,
        overflow: pw.TextOverflow.clip,
      ),
    );
  }

  pw.Widget _buildTotalRowPdf(String label, String value, pw.Font font, bool isRTL) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: 14, color: PdfColors.grey), textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr),
          pw.Text(value, style: pw.TextStyle(font: font, fontSize: 14, color: PdfColors.white)),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

}

 */

/*
import 'package:aboomar/main.dart';
import '../../services/api_exceptions.dart';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../app_localizations.dart';
import '../../models/branch_delivery_model.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';
import 'widgets/delivery_data_table.dart';
import 'widgets/grand_total_card.dart';

class BranchDeliveryScreen extends StatefulWidget {
  final DateTime selectedDate;
  const BranchDeliveryScreen({super.key, required this.selectedDate});

  @override
  State<BranchDeliveryScreen> createState() => _BranchDeliveryScreenState();
}

class _BranchDeliveryScreenState extends State<BranchDeliveryScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  ApiException? _apiException;
  List<BranchDelivery>? _deliveries;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _apiException = null;
    });

    try {
      final deliveries = await _apiService.getBranchDeliveries(widget.selectedDate);
      if (!mounted) return;
      setState(() {
        _deliveries = deliveries;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _apiException = e;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.translate("branch_shifts_delivery")),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: (_deliveries != null && _deliveries!.isNotEmpty)
                ? () => _generatePDF(_deliveries!)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.language_outlined, color: Colors.white),
            onPressed: () {
              final currentLocale = Localizations.localeOf(context);
              final newLocale = currentLocale.languageCode == 'en'
                  ? const Locale('ar', '')
                  : const Locale('en', '');
              MyApp.of(context)?.changeLanguage(newLocale);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_apiException != null) {
      return _buildErrorWidget(context, _apiException!);
    }
    if (_deliveries == null || _deliveries!.isEmpty) {
      return Center(child: Text(l.translate("no_data_available")));
    }
    return Column(
      children: [
        Expanded(
          child: DeliveryDataTable(deliveries: _deliveries!),
        ),
        GrandTotalCard(
          totalCash: _deliveries!.fold(0, (sum, item) => sum + item.cashAmount),
          totalVisa: _deliveries!.fold(0, (sum, item) => sum + item.visaAmount),
          totalExpenses: _deliveries!.fold(0, (sum, item) => sum + item.expensesAmount),
          grandTotal: _deliveries!.fold(0, (sum, item) => sum + item.total),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(BuildContext context, ApiException error) {
    final localizations = AppLocalizations.of(context)!;
    final isNetworkError = error is NoInternetException;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isNetworkError ? Icons.wifi_off : Icons.cloud_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            localizations.translate(error.toString()),
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: Text(localizations.translate('retry')),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePDF(List<BranchDelivery> deliveries) async {
    if (deliveries.isEmpty) {
      _showSnackBar('لا توجد بيانات لتصدير PDF');
      return;
    }

    final pdf = pw.Document();

    try {
      // -- بداية الحل النهائي --
      // العودة لاستخدام خط Cairo لأنه يعرض الأرقام بالشكل الصحيح
      final regularFont = await PdfGoogleFonts.cairoRegular();
      final boldFont = await PdfGoogleFonts.cairoBold();
      // -- نهاية الحل النهائي --

      final l = AppLocalizations.of(context)!;
      final formatter = NumberFormat("#,##0.00", "en_US");
      final currentLocale = Localizations.localeOf(context);
      final isRTL = currentLocale.languageCode == 'ar';
      final printDateTime = DateTime.now();

      final double totalCash = deliveries.fold(0, (sum, item) => sum + item.cashAmount);
      final double totalVisa = deliveries.fold(0, (sum, item) => sum + item.visaAmount);
      final double totalExpenses = deliveries.fold(0, (sum, item) => sum + item.expensesAmount);
      final double grandTotal = deliveries.fold(0, (sum, item) => sum + item.total);

      const int rowsPerPage = 18;
      final List<List<BranchDelivery>> pages = [];
      for (int i = 0; i < deliveries.length; i += rowsPerPage) {
        pages.add(deliveries.sublist(i, i + rowsPerPage > deliveries.length ? deliveries.length : i + rowsPerPage));
      }

      for (int pageIndex = 0; pageIndex < pages.length; pageIndex++) {
        final pageData = pages[pageIndex];

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(15),
            textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(10),
                    margin: const pw.EdgeInsets.only(bottom: 15),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#3F51B5'),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(l.translate("branch_shifts_delivery"), style: pw.TextStyle(font: boldFont, fontSize: 20, color: PdfColors.white), textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr),
                        pw.SizedBox(height: 5),
                        pw.Text('${l.translate("date")}: ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}', style: pw.TextStyle(font: regularFont, fontSize: 16, color: PdfColors.white)),
                        pw.SizedBox(height: 5),
                        pw.Text('${l.translate("print_date")}: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(printDateTime)}', style: pw.TextStyle(font: regularFont, fontSize: 14, color: PdfColors.grey)),
                      ],
                    ),
                  ),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                    columnWidths: {
                      0: const pw.FixedColumnWidth(40),
                      1: const pw.FixedColumnWidth(50),
                      2: const pw.FlexColumnWidth(2.2),
                      3: const pw.FlexColumnWidth(1.5),
                      4: const pw.FlexColumnWidth(1.5),
                      5: const pw.FlexColumnWidth(1.5),
                      6: const pw.FlexColumnWidth(1.6),
                    },
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColor.fromHex('#3F51B5')),
                        children: [
                          _buildCompactPdfCell(l.translate("serial"), boldFont, PdfColors.white, 12),
                          _buildCompactPdfCell(l.translate("date"), boldFont, PdfColors.white, 12),
                          _buildCompactPdfCell(l.translate("branch"), boldFont, PdfColors.white, 12),
                          _buildCompactPdfCell(l.translate("cash"), boldFont, PdfColors.white, 12),
                          _buildCompactPdfCell(l.translate("visa"), boldFont, PdfColors.white, 12),
                          _buildCompactPdfCell(l.translate("expenses"), boldFont, PdfColors.white, 12),
                          _buildCompactPdfCell(l.translate("total"), boldFont, PdfColors.white, 12),
                        ],
                      ),
                      ...pageData.asMap().entries.map((entry) {
                        final globalIndex = (pageIndex * rowsPerPage) + entry.key;
                        final delivery = entry.value;
                        final isEven = globalIndex % 2 == 0;
                        return pw.TableRow(
                          decoration: pw.BoxDecoration(color: isEven ? PdfColors.grey50 : PdfColors.white),
                          children: [
                            _buildCompactPdfCell((globalIndex + 1).toString(), regularFont, PdfColors.black, 11),
                            _buildCompactPdfCell(DateFormat('MM-dd').format(DateTime.parse(delivery.trnsDate)), regularFont, PdfColors.black, 11),
                            _buildCompactPdfCell(delivery.branchName, regularFont, PdfColors.black, 11),
                            _buildCompactPdfCell(formatter.format(delivery.cashAmount), regularFont, PdfColor.fromHex('#2E7D32'), 11),
                            _buildCompactPdfCell(formatter.format(delivery.visaAmount), regularFont, PdfColor.fromHex('#1565C0'), 11),
                            _buildCompactPdfCell(formatter.format(delivery.expensesAmount), regularFont, PdfColor.fromHex('#C62828'), 11),
                            _buildCompactPdfCell(formatter.format(delivery.total), boldFont, PdfColor.fromHex('#7B1FA2'), 11),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      '${l.translate("page")} ${pageIndex + 1} ${l.translate("of")} ${pages.length}',
                      style: pw.TextStyle(font: regularFont, fontSize: 14, color: PdfColors.grey),
                    ),
                  ),
                  if (pageIndex == pages.length - 1) ...[
                    pw.SizedBox(height: 20),
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#3F51B5'),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(l.translate("grand_total"), style: pw.TextStyle(font: boldFont, fontSize: 18, color: PdfColors.white), textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr),
                          pw.SizedBox(height: 5),
                          _buildTotalRowPdf(l.translate("total_cash"), formatter.format(totalCash), regularFont, isRTL),
                          _buildTotalRowPdf(l.translate("total_visa"), formatter.format(totalVisa), regularFont, isRTL),
                          _buildTotalRowPdf(l.translate("total_expenses"), formatter.format(totalExpenses), regularFont, isRTL),
                          pw.Divider(color: PdfColors.grey, height: 8),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(l.translate("total"), style: pw.TextStyle(font: boldFont, fontSize: 18, color: PdfColors.white), textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr),
                              pw.Text(formatter.format(grandTotal), style: pw.TextStyle(font: boldFont, fontSize: 18, color: PdfColors.white)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        );
      }

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
      _showSnackBar('تم إنشاء PDF بنجاح');

    } catch (e) {
      _showSnackBar('خطأ في إنشاء PDF: $e');
    }
  }

  pw.Widget _buildCompactPdfCell(
      String text,
      pw.Font font,
      PdfColor color,
      double fontSize,
      ) {
    // دالة بسيطة للتحقق مما إذا كان النص يحتوي على حروف إنجليزية
    final bool containsEnglish = text.contains(RegExp(r'[a-zA-Z]'));

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      alignment: pw.Alignment.center,
      child: pw.FittedBox(
        child: pw.Text(
          text,
          style: pw.TextStyle(font: font, fontSize: fontSize, color: color),
          textAlign: pw.TextAlign.center,
          // -- بداية الحل النهائي --
          // تحديد اتجاه النص ديناميكيًا: إذا كان يحتوي على حروف إنجليزية، اجعله من اليسار لليمين
          textDirection: containsEnglish ? pw.TextDirection.ltr : pw.TextDirection.rtl,
          // -- نهاية الحل النهائي --
        ),
      ),
    );
  }

  pw.Widget _buildTotalRowPdf(String label, String value, pw.Font font, bool isRTL) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: 14, color: PdfColors.grey), textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr),
          pw.Text(value, style: pw.TextStyle(font: font, fontSize: 14, color: PdfColors.white)),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
*/

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../app_localizations.dart';
import '../../main.dart';
import '../../models/branch_delivery_model.dart';
import '../../services/api_exceptions.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';
import 'widgets/delivery_data_table.dart';
import 'widgets/grand_total_card.dart';

class BranchDeliveryScreen extends StatefulWidget {
  final DateTime selectedDate;
  const BranchDeliveryScreen({super.key, required this.selectedDate});

  @override
  State<BranchDeliveryScreen> createState() => _BranchDeliveryScreenState();
}

class _BranchDeliveryScreenState extends State<BranchDeliveryScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  ApiException? _apiException;
  List<BranchDelivery>? _deliveries;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _apiException = null;
    });

    try {
      final deliveries = await _apiService.getBranchDeliveries(widget.selectedDate);
      if (!mounted) return;
      setState(() {
        _deliveries = deliveries;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _apiException = e;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ... باقي الكود مثل build, _buildBody, _buildErrorWidget يبقى كما هو ...

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(l.translate("branch_shifts_delivery"),style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined,color: Colors.white),
            onPressed: (_deliveries != null && _deliveries!.isNotEmpty)
                ? () => _generatePDF(context, _deliveries!) // تمرير context
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.language_outlined, color: Colors.white),
            onPressed: () {
              final currentLocale = Localizations.localeOf(context);
              final newLocale = currentLocale.languageCode == 'en'
                  ? const Locale('ar', '')
                  : const Locale('en', '');
              MyApp.of(context)?.changeLanguage(newLocale);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_apiException != null) {
      return _buildErrorWidget(context, _apiException!);
    }
    if (_deliveries == null || _deliveries!.isEmpty) {
      return Center(child: Text(l.translate("no_data_available")));
    }
    return Column(
      children: [
        Expanded(
          child: DeliveryDataTable(deliveries: _deliveries!),
        ),
        GrandTotalCard(
          totalCash: _deliveries!.fold(0, (sum, item) => sum + item.cashAmount),
          totalVisa: _deliveries!.fold(0, (sum, item) => sum + item.visaAmount),
          totalExpenses: _deliveries!.fold(0, (sum, item) => sum + item.expensesAmount),
          grandTotal: _deliveries!.fold(0, (sum, item) => sum + item.total),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(BuildContext context, ApiException error) {
    final localizations = AppLocalizations.of(context)!;
    final isNetworkError = error is NoInternetException;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isNetworkError ? Icons.wifi_off : Icons.cloud_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            localizations.translate(error.toString()),
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: Text(localizations.translate('retry')),
          ),
        ],
      ),
    );
  }


  // ---------------------------------------------------------------------------
  // -- بداية التعديل الجذري --
  // ---------------------------------------------------------------------------

  // تم تغيير اسم الدالة وتمرير context
  static Future<void> _generatePDF(BuildContext context, List<BranchDelivery> deliveries) async {
    if (deliveries.isEmpty) {
      _showSnackBar(context, 'لا توجد بيانات لتصدير PDF');
      return;
    }

    try {
      final regularFont = await PdfGoogleFonts.cairoRegular();
      final boldFont = await PdfGoogleFonts.cairoBold();

      final l = AppLocalizations.of(context)!;
      final isRTL = Localizations.localeOf(context).languageCode == 'ar';
      final formatter = NumberFormat("#,##0.00", "en_US");

      final double totalCash = deliveries.fold(0, (sum, item) => sum + item.cashAmount);
      final double totalVisa = deliveries.fold(0, (sum, item) => sum + item.visaAmount);
      final double totalExpenses = deliveries.fold(0, (sum, item) => sum + item.expensesAmount);
      final double grandTotal = deliveries.fold(0, (sum, item) => sum + item.total);

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          header: (pw.Context pdfContext) => _buildHeader(
            l,
            deliveries.first.trnsDate, // استخدام تاريخ أول عنصر كمرجع
            boldFont,
            regularFont,
            isRTL,
          ),
          footer: (pw.Context pdfContext) {
            return pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Text(
                '${l.translate("page")} ${pdfContext.pageNumber} ${l.translate("of")} ${pdfContext.pagesCount}',
                style: pw.TextStyle(font: regularFont, fontSize: 10),
              ),
            );
          },
          build: (pw.Context pdfContext) => [
            _buildTable(l, deliveries, boldFont, regularFont, formatter),
            pw.SizedBox(height: 20),
            _buildGrandTotal(l, totalCash, totalVisa, totalExpenses, grandTotal, boldFont, regularFont, formatter, isRTL),
          ],
        ),
      );

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());

    } catch (e) {
      _showSnackBar(context, 'خطأ في إنشاء PDF: $e');
    }
  }

  static pw.Widget _buildHeader(AppLocalizations l, String dateStr, pw.Font boldFont, pw.Font regularFont, bool isRTL) {
    // التحقق من التاريخ وتحويله
    final DateTime date = DateTime.tryParse(dateStr) ?? DateTime.now();

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: isRTL ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            l.translate("branch_shifts_delivery"),
            style: pw.TextStyle(font: boldFont, fontSize: 22, color: PdfColor.fromHex('#3F51B5')),
            textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '${l.translate("date")}: ${DateFormat('dd-MM-yyyy').format(date)}',
            style: pw.TextStyle(font: regularFont, fontSize: 14),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            '${l.translate("print_date")}: ${DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now())}',
            style: pw.TextStyle(font: regularFont, fontSize: 12, color: PdfColors.grey700),
          ),
          pw.Divider(height: 15, thickness: 1),
        ],
      ),
    );
  }

  static pw.Table _buildTable(AppLocalizations l, List<BranchDelivery> deliveries, pw.Font boldFont, pw.Font regularFont, NumberFormat formatter) {
    final headers = [
      l.translate("serial"),
      l.translate("date"),
      l.translate("branch"),
      l.translate("cash"),
      l.translate("visa"),
      l.translate("expenses"),
      l.translate("total"),
    ];

    return pw.Table.fromTextArray(
      headers: headers,
      data: deliveries.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        return [
          (index + 1).toString(),
          DateFormat('MM-dd').format(DateTime.parse(data.trnsDate)),
          data.branchName,
          formatter.format(data.cashAmount),
          formatter.format(data.visaAmount),
          formatter.format(data.expensesAmount),
          formatter.format(data.total),
        ];
      }).toList(),
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
      headerStyle: pw.TextStyle(font: boldFont, fontSize: 11, color: PdfColors.white),
      headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#3F51B5')),
      cellStyle: pw.TextStyle(font: regularFont, fontSize: 10),
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
        6: pw.Alignment.centerRight,
      },
      // لا نحدد عرض الأعمدة هنا، نترك المكتبة تقوم بذلك تلقائياً
    );
  }

  static pw.Widget _buildGrandTotal(AppLocalizations l, double cash, double visa, double expenses, double total, pw.Font boldFont, pw.Font regularFont, NumberFormat formatter, bool isRTL) {
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
            style: pw.TextStyle(font: boldFont, fontSize: 16),
            textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          ),
          pw.Divider(height: 10),
          _buildTotalRowPdf(l.translate("total_cash"), formatter.format(cash), regularFont, boldFont, isRTL),
          _buildTotalRowPdf(l.translate("total_visa"), formatter.format(visa), regularFont, boldFont, isRTL),
          _buildTotalRowPdf(l.translate("total_expenses"), formatter.format(expenses), regularFont, boldFont, isRTL),
          pw.Divider(height: 10, thickness: 1, color: PdfColor.fromHex('#3F51B5')),
          _buildTotalRowPdf(l.translate("total"), formatter.format(total), regularFont, boldFont, isRTL, isGrandTotal: true),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalRowPdf(String label, String value, pw.Font regularFont, pw.Font boldFont, bool isRTL, {bool isGrandTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: isGrandTotal ? boldFont : regularFont, fontSize: isGrandTotal ? 14 : 12), textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr),
          pw.Text(value, style: pw.TextStyle(font: boldFont, fontSize: isGrandTotal ? 15 : 13)),
        ],
      ),
    );
  }

  static void _showSnackBar(BuildContext context, String message) {
    if (ScaffoldMessenger.of(context).mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

// تم حذف دالة _buildCompactPdfCell لأنها لم تعد مستخدمة
}