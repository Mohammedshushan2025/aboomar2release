/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aboomar/app_localizations.dart';

class GrandTotalCard extends StatelessWidget {
  final double totalQuantity;
  final double totalSales;
  final double totalBalance;

  const GrandTotalCard({
    super.key,
    required this.totalQuantity,
    required this.totalSales,
    required this.totalBalance,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final formatter = NumberFormat("#,##0.00", "en_US");

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l.translate("grand_total"),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Divider(color: Colors.white54, height: 20),
          _buildTotalRow(l.translate("total_quantity"), formatter.format(totalQuantity)),
          const SizedBox(height: 8),
          _buildTotalRow(l.translate("total_sales"), formatter.format(totalSales)),
          const SizedBox(height: 8),
          _buildTotalRow(l.translate("total_balance"), formatter.format(totalBalance)),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, color: Colors.white70)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}
*/


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aboomar2release/app_localizations.dart';

class GrandTotalCard extends StatelessWidget {
  final double totalQuantity;
  final double totalSales;
  final double totalBalance;

  const GrandTotalCard({
    super.key,
    required this.totalQuantity,
    required this.totalSales,
    required this.totalBalance,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final formatter = NumberFormat("#,##0.00", "en_US");

    return Container(
      // تقليل الهوامش والـ padding
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark, // لون أغمق قليلاً للتميز
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // عرض الإجماليات في صف واحد لتقليل الارتفاع
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTotalItem(l.translate("total_quantity"), formatter.format(totalQuantity), context),
              _buildTotalItem(l.translate("total_sales"), formatter.format(totalSales), context),
              _buildTotalItem(l.translate("total_balance"), formatter.format(totalBalance), context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalItem(String label, String value, BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          // تصغير حجم الخط
          style: const TextStyle(fontSize: 13, color: Colors.white70),
        ),
        const SizedBox(height: 4), // تقليل المسافة
        Text(
          value,
          // تصغير حجم الخط
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }
}