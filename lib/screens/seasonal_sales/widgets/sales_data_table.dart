/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aboomar/models/seasonal_sales_model.dart';
import 'package:aboomar/app_localizations.dart';

class SalesDataTable extends StatelessWidget {
  final List<SeasonalSalesData> salesData;
  const SalesDataTable({super.key, required this.salesData});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final formatter = NumberFormat("#,##0.00", "en_US");

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: DataTable(
          columnSpacing: 16.0,
          headingRowColor: MaterialStateProperty.all(Theme.of(context).primaryColor.withOpacity(0.1)),
          columns: [
            DataColumn(label: Text(l.translate("serial_short"))),
            DataColumn(label: Text(l.translate("branch"))),
            DataColumn(label: Text(l.translate("quantity")), numeric: true),
            DataColumn(label: Text(l.translate("total_sales")), numeric: true),
            DataColumn(label: Text(l.translate("balance")), numeric: true),
          ],
          rows: salesData.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            return DataRow(
              cells: [
                DataCell(Text((index + 1).toString())),
                DataCell(Text(data.branchName)),
                DataCell(Text(formatter.format(data.quantity))),
                DataCell(Text(formatter.format(data.totalCost))),
                DataCell(Text(formatter.format(data.balance))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aboomar2release/models/seasonal_sales_model.dart';
import 'package:aboomar2release/app_localizations.dart';
import 'package:data_table_2/data_table_2.dart'; // <-- 1. استيراد الحزمة الجديدة

class SalesDataTable extends StatelessWidget {
  final List<SeasonalSalesData> salesData;
  final Function(SeasonalSalesData) onRowTap;

  const SalesDataTable({
    super.key,
    required this.salesData,
    required this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final formatter = NumberFormat("#,##0.00", "en_US");

    // <-- 2. تم إزالة ويدجتس الـ SingleChildScrollView بالكامل
    // حزمة data_table_2 تدير السكرول بنفسها
    return DataTable2(
      // <-- 3. استخدام DataTable2 بدلاً من DataTable
      columnSpacing: 12.0,
      horizontalMargin: 12.0,
      minWidth: 350, // <-- عرض أدنى للجدول، سيظهر سكرول أفقي إذا كانت الشاشة أصغر
      fixedTopRows: 1, // <-- 4. السحر كله هنا: تثبيت أول صف (الـ Header)

      headingRowColor: MaterialStateProperty.all(Theme.of(context).primaryColor.withOpacity(0.1)),
      headingTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),

      // <-- 5. استخدام DataColumn2 للتحكم الدقيق في حجم الأعمدة
      columns: [
        DataColumn2(
          label: Center(child: Text(l.translate("serial_short"))),
          size: ColumnSize.S, // <-- تحديد حجم صغير لعمود المسلسل
          fixedWidth: 20, // عرض ثابت
        ),
        DataColumn2(
          label: Center(child: Text(l.translate("branch"))),
          size: ColumnSize.S, // <-- تحديد حجم كبير لعمود اسم الفرع
        ),
        DataColumn2(
          label: Center(child: Text(l.translate("quantity"))),
          size: ColumnSize.S, // حجم متوسط
          numeric: true,
        ),
        DataColumn2(
          label: Center(child: Text(l.translate("total_sales"),style: TextStyle(fontSize: 12),)),

          numeric: true,
        ),
        DataColumn2(
          label: Center(child: Text(l.translate("balance"))),
          size: ColumnSize.S,
          numeric: true,
        ),
      ],
      rows: salesData.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;

        return DataRow2(
          // استخدام DataRow2
          color: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (index.isEven) return Colors.grey.withOpacity(0.05);
              return null;
            },
          ),
          // عند الضغط على الصف كاملاً
          onTap: () => onRowTap(data),
          cells: [
            DataCell(Center(child: Text((index + 1).toString(),style: TextStyle(
                fontSize: 12
            ),))),
            DataCell(Center(child: Text(data.branchName, overflow: TextOverflow.ellipsis,maxLines: 2,style: TextStyle(
                fontSize: 12
            ),))),
            DataCell(Center(child: Text(formatter.format(data.quantity),style: TextStyle(
                fontSize: 12
            ),))),
            DataCell(Center(child: Text(formatter.format(data.totalCost),style: TextStyle(
                fontSize: 12
            ),))),
            DataCell(Center(child: Text(formatter.format(data.balance),style: TextStyle(
              fontSize: 12
            ),))),
          ],
        );
      }).toList(),
    );
  }
}