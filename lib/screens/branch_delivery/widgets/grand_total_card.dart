import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app_localizations.dart';

class GrandTotalCard extends StatelessWidget {
  final double totalCash;
  final double totalVisa;
  final double totalExpenses;
  final double grandTotal;

  const GrandTotalCard({
    super.key,
    required this.totalCash,
    required this.totalVisa,
    required this.totalExpenses,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final formatter = NumberFormat("#,##0.00", "en_US");

    return Card(
      margin: const EdgeInsets.all(4),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).primaryColor.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              l.translate("grand_total"),

              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.white54, height: 10),
            _buildTotalRow(l.translate("total_cash"), formatter.format(totalCash)),
            _buildTotalRow(l.translate("total_visa"), formatter.format(totalVisa)),
            _buildTotalRow(l.translate("total_expenses"), formatter.format(totalExpenses)),
            const Divider(color: Colors.white54, height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.translate("total"),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  formatter.format(grandTotal),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}