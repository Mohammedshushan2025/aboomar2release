import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app_localizations.dart';
import '../../../models/daily_summary_model.dart';

class DailyPerformanceWidget extends StatelessWidget {
  final DailySummary summary;
  final bool hideRevenue;

  const DailyPerformanceWidget({
    super.key, 
    required this.summary, 
    this.hideRevenue = false,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    print(l.translate("daily_performance"));
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.analytics,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l.locale == 'ar'
                    ? l.translate("daily_performance")
                    : l.translate("daily_performance"),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // استخدام LayoutBuilder للتحكم في التخطيط حسب حجم الشاشة
          LayoutBuilder(
            builder: (context, constraints) {
              // إذا كانت الشاشة صغيرة، استخدم عمود واحد
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            icon: Icons.account_balance_wallet_outlined,
                            label: l.translate("total_cash"),
                            value: summary.cashAmount,
                            color: const Color(0xFF4CAF50),
                            backgroundColor: const Color(0xFFE8F5E8),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            icon: Icons.credit_card,
                            label: l.translate("total_visa"),
                            value: summary.visaAmount,
                            color: const Color(0xFF2196F3),
                            backgroundColor: const Color(0xFFE3F2FD),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            icon: Icons.trending_up,
                            label: l.translate("total_revenue"),
                            value: summary.total,
                            color: const Color(0xFF9C27B0),
                            backgroundColor: const Color(0xFFF3E5F5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            icon: Icons.receipt_long_outlined,
                            label: l.translate("total_expenses"),
                            value: summary.expensesAmount,
                            color: const Color(0xFFFF9800),
                            backgroundColor: const Color(0xFFFFF3E0),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }

              // للشاشات الكبيرة، استخدم GridView
              return GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
                children: [
                  _buildInfoCard(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    label: l.translate("total_cash"),
                    value: summary.cashAmount,
                    color: const Color(0xFF4CAF50),
                    backgroundColor: const Color(0xFFE8F5E8),
                  ),
                  _buildInfoCard(
                    context,
                    icon: Icons.credit_card,
                    label: l.translate("total_visa"),
                    value: summary.visaAmount,
                    color: const Color(0xFF2196F3),
                    backgroundColor: const Color(0xFFE3F2FD),
                  ),
                  _buildInfoCard(
                    context,
                    icon: Icons.trending_up,
                    label: l.translate("total_revenue"),
                    value: summary.total,
                    color: const Color(0xFF9C27B0),
                    backgroundColor: const Color(0xFFF3E5F5),
                  ),
                  _buildInfoCard(
                    context,
                    icon: Icons.receipt_long_outlined,
                    label: l.translate("total_expenses"),
                    value: summary.expensesAmount,
                    color: const Color(0xFFFF9800),
                    backgroundColor: const Color(0xFFFFF3E0),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {
    required IconData icon,
    required String label,
    required double value,
    required Color color,
    required Color backgroundColor,
  }) {
    // تنسيق الأرقام بالأرقام الكاملة مع فواصل
    String formatValue(double val) {
      if (hideRevenue) return '***';
      final formatter = NumberFormat('#,##0', 'ar');
      return formatter.format(val.round());
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            FittedBox(
              child: Text(
                formatValue(value),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}