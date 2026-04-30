import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app_localizations.dart';
import '../../../models/branch_delivery_model.dart';

class BranchDeliveryCard extends StatelessWidget {
  final int serialNumber;
  final BranchDelivery delivery;
  final VoidCallback onTap;

  const BranchDeliveryCard({
    super.key,
    required this.serialNumber,
    required this.delivery,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,##0.00", "en_US");

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // الصف الرئيسي الذي يظهر في القائمة
              Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      '$serialNumber.',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      delivery.branchName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      formatter.format(delivery.total),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
              const Divider(height: 24),
              // تفاصيل إضافية داخل البطاقة
              _buildDetailRow(context, AppLocalizations.of(context)!.translate("cash"), formatter.format(delivery.cashAmount)),
              const SizedBox(height: 8),
              _buildDetailRow(context, AppLocalizations.of(context)!.translate("visa"), formatter.format(delivery.visaAmount)),
              const SizedBox(height: 8),
              _buildDetailRow(context, AppLocalizations.of(context)!.translate("expenses"), formatter.format(delivery.expensesAmount)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[700], fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ],
    );
  }
}