/*
import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import 'package:aboomar/screens/branch_delivery/branch_delivery_screen.dart';

class HomeActionCards extends StatelessWidget {
  final DateTime selectedDate;
  const HomeActionCards({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  Icons.dashboard,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l.translate("action_cards"),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // تسليم نوبات الفروع
          _buildActionCard(
            context: context,
            icon: Icons.store,
            iconColor: const Color(0xFF4CAF50),
            backgroundColor: const Color(0xFFE8F5E8),
            title: l.translate("branch_shifts_delivery"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BranchDeliveryScreen(selectedDate: selectedDate),
                ),
              );
            },
          ),

          // التقارير والتحليلات
          _buildActionCard(
            context: context,
            icon: Icons.analytics,
            iconColor: const Color(0xFF2196F3),
            backgroundColor: const Color(0xFFE3F2FD),
            title: l.translate("temp_card_title"),

            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l.translate("work_in_progress")),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              );
            },
          ),

          // إدارة المخزون
          _buildActionCard(
            context: context,
            icon: Icons.inventory_2,
            iconColor: const Color(0xFFFF9800),
            backgroundColor: const Color(0xFFFFF3E0),
            title: l.translate("temp_card_title"),

            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l.translate("work_in_progress")),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: backgroundColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // أيقونة مع خلفية ملونة
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                // النص
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),

                    ],
                  ),
                ),

                // سهم التنقل
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/


import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../branch_delivery/branch_delivery_screen.dart';
import '../../seasonal_sales/seasonal_sales_screen.dart';
import '../../seasonal_sales/seasonal_sales_total_screen.dart'; // إضافة الاستيراد هنا

class HomeActionCards extends StatelessWidget {
  final DateTime selectedDate;
  final bool hideRevenueCard;
  final bool hideSalesDetailsCard;
  final bool hideSeasonSalesCard;

  const HomeActionCards({
    super.key, 
    required this.selectedDate,
    this.hideRevenueCard = false,
    this.hideSalesDetailsCard = false,
    this.hideSeasonSalesCard = false,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... (كود العنوان "إجراءات سريعة" يبقى كما هو)

          const SizedBox(height: 16),

          // تسليم نوبات الفروع
          if (!hideRevenueCard)
            _buildActionCard(
              context: context,
              icon: Icons.store,
              iconColor: const Color(0xFF4CAF50),
              backgroundColor: const Color(0xFFE8F5E8),
              title: l.translate("branch_shifts_delivery"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BranchDeliveryScreen(selectedDate: selectedDate),
                  ),
                );
              },
            ),

          // ==== الكرت الثاني ====
          if (!hideSalesDetailsCard)
            _buildActionCard(
              context: context,
              icon: Icons.cake, // أيقونة مناسبة للحلويات
              iconColor: const Color(0xFF2196F3),
              backgroundColor: const Color(0xFFE3F2FD),
              title: l.translate("seasonal_sales_categories"), // استخدام مفتاح ترجمة جديد
              onTap: () {
                // الانتقال إلى الشاشة الجديدة مع تمرير التاريخ المختار
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SeasonalSalesScreen(initialDate: selectedDate),
                  ),
                );
              },
            ),
          
          if (!hideSeasonSalesCard)
            _buildActionCard(
              context: context,
              icon: Icons.summarize,
              iconColor: const Color(0xFFFF9800),
              backgroundColor: const Color(0xFFFFF3E0),
              title: l.translate("seasonal_sales_total"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SeasonalSalesTotalScreen(initialDate: selectedDate),
                  ),
                );
              },
            ),
/*
          // الكرت الثالث (يبقى كما هو)
          _buildActionCard(
            context: context,
            icon: Icons.inventory_2,
            iconColor: const Color(0xFFFF9800),
            backgroundColor: const Color(0xFFFFF3E0),
            title: l.translate("temp_card_title"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l.translate("work_in_progress")),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              );
            },
          ),
          */
        ],
      ),
    );
  }

  // ... (دالة _buildActionCard تبقى كما هي)
  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: backgroundColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // أيقونة مع خلفية ملونة
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                // النص
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),

                    ],
                  ),
                ),

                // سهم التنقل
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}