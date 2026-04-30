

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app_localizations.dart';
import '../../../models/branch_delivery_model.dart';

class DeliveryDataTable extends StatefulWidget {
  final List<BranchDelivery> deliveries;
  const DeliveryDataTable({super.key, required this.deliveries});

  @override
  State<DeliveryDataTable> createState() => _DeliveryDataTableState();
}

class _DeliveryDataTableState extends State<DeliveryDataTable> {
  late ScrollController _horizontalScrollController;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final formatter = NumberFormat("#,##0.00", "en_US");

    return Container(
      margin: const EdgeInsets.all(8.0),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // الجدول بالكامل مع horizontal scroll واحد
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 28,
                    dataRowHeight: 25,
                    columnSpacing: 8,
                    horizontalMargin: 8,
                    headingRowColor: MaterialStateProperty.all(
                      Theme.of(context).primaryColor,
                    ),
                    columns: [
                      DataColumn(
                        label: Container(
                          width: 50,
                          child: Text(
                            l.translate("serial"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Container(
                          width: 60,
                          child: Text(
                            l.translate("date"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Container(
                          width: 80,
                          child: Text(
                            l.translate("branch"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Container(
                          width: 60,
                          child: Text(
                            l.translate("cash"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Container(
                          width: 60,
                          child: Text(
                            l.translate("visa"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Container(
                          width: 70,
                          child: Text(
                            l.translate("expenses"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Container(
                          width: 60,
                          child: Text(
                            l.translate("total"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Container(
                          width: 40,
                          child: Text(
                            l.translate("view_details"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                    rows: widget.deliveries.asMap().entries.map((entry) {
                      final index = entry.key;
                      final delivery = entry.value;

                      return DataRow(
                        color: MaterialStateProperty.all(
                          index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
                        ),
                        cells: [
                          DataCell(
                            Container(
                              width: 30,
                              child: Text(
                                (index + 1).toString(),
                                style: const TextStyle(fontSize: 8),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              width: 60,
                              child: Text(
                                DateFormat('MM-dd').format(DateTime.parse(delivery.trnsDate)),
                                style: const TextStyle(fontSize: 8),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              width: 80,
                              child: Text(
                                delivery.branchName,
                                style: const TextStyle(fontSize: 8),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              width: 60,
                              child: Text(
                                formatter.format(delivery.cashAmount),
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              width: 60,
                              child: Text(
                                formatter.format(delivery.visaAmount),
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              width: 70,
                              child: Text(
                                formatter.format(delivery.expensesAmount),
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              width: 60,
                              child: Text(
                                formatter.format(delivery.total),
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.purple.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              width: 50,
                              child: Center(
                                child: IconButton(
                                  icon: Icon(
                                    Icons.visibility,
                                    color: Colors.blue.shade700,
                                    size: 12,
                                  ),
                                  onPressed: () {
                                    _showDeliveryDetails(context, delivery, l);
                                  },
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeliveryDetails(BuildContext context, BranchDelivery delivery, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.info, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.locale=="en"?"تفاصيل":"Details",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(l.translate("branch"), delivery.branchName),
                _buildDetailRow(l.translate("date"), DateFormat('yyyy-MM-dd').format(DateTime.parse(delivery.trnsDate))),
                _buildDetailRow(l.translate("cash"), NumberFormat("#,##0.00", "en_US").format(delivery.cashAmount)),
                _buildDetailRow(l.translate("visa"), NumberFormat("#,##0.00", "en_US").format(delivery.visaAmount)),
                _buildDetailRow(l.translate("expenses"), NumberFormat("#,##0.00", "en_US").format(delivery.expensesAmount)),
                const Divider(),
                _buildDetailRow(l.translate("total"), NumberFormat("#,##0.00", "en_US").format(delivery.total), isTotal: true),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l.translate("close")),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                fontSize: isTotal ? 16 : 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 16 : 14,
                color: isTotal ? Colors.purple.shade700 : Colors.grey.shade800,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}