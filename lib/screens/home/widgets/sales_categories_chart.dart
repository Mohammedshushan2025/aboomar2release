import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../models/sales_category_model.dart';

class SalesCategoriesChart extends StatelessWidget {
  final List<SalesCategory> categories;
  const SalesCategoriesChart({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    // عرض جميع التصنيفات بدلاً من 10 فقط
    final displayCategories = categories;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E3A8A),
                Color(0xFF3B82F6),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.bar_chart,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l.translate("total_sales_quantities_by_category") ?? "إجمالي مبيعات وكميات لكل تصنيف",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // إضافة Legend للألوان فقط
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildColorLegendItem('الكمية', Colors.greenAccent),
                    const SizedBox(width: 24),
                    _buildColorLegendItem('المبيعات', Colors.amberAccent),
                  ],
                ),
                const SizedBox(height: 16),

                // إضافة الرسم البياني في SingleChildScrollView للسكرول الأفقي
                SizedBox(
                  height: 300, // زيادة ارتفاع الرسم لإعطاء مساحة أكبر
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: _calculateChartWidth(displayCategories.length),
                      padding: const EdgeInsets.only(top: 20, bottom: 10), // إضافة padding علوي وسفلي
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _getMaxY(displayCategories),
                          minY: 0,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              fitInsideHorizontally: true,
                              fitInsideVertically: true,
                              tooltipRoundedRadius: 8,
                              tooltipPadding: const EdgeInsets.all(8),
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                if (group.x.toInt() >= displayCategories.length) return null;

                                String categoryName = displayCategories[group.x.toInt()].categoryName;
                                double value = rod.toY;
                                String label = rodIndex == 0 ? 'الكمية' : 'المبيعات';

                                return BarTooltipItem(
                                  categoryName,
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  children: <TextSpan>[
                                    const TextSpan(text: '\n'),
                                    TextSpan(
                                      text: '$label: ${value.toStringAsFixed(0)}', // إظهار الرقم الفعلي بدون K أو M
                                      style: const TextStyle(
                                        color: Colors.amberAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) => _bottomTitles(value, meta, displayCategories),
                                reservedSize: 40, // تقليل المساحة المحجوزة
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40, // تقليل المساحة المحجوزة
                                interval: _getInterval(displayCategories),
                                getTitlesWidget: _leftTitles,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: _generateBarGroups(displayCategories),
                          groupsSpace: 10, // تقليل المساحة بين المجموعات من 30 إلى 10
                          gridData: FlGridData(
                            show: true,
                            drawHorizontalLine: true,
                            drawVerticalLine: false,
                            horizontalInterval: _getInterval(displayCategories),
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.white.withOpacity(0.1),
                                strokeWidth: 1,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // إزالة Legend التفاصيل
              ],
            ),
          ),
        ),
      ),
    );
  }

  // حساب عرض الرسم البياني حسب عدد التصنيفات
  double _calculateChartWidth(int categoriesCount) {
    // كل تصنيف يحتاج مساحة تقريبية 70 بكسل (تقليل من 80)
    double minWidth = 800; // الحد الأدنى للعرض
    double calculatedWidth = categoriesCount * 70.0;
    return calculatedWidth > minWidth ? calculatedWidth : minWidth;
  }

  // بناء legend item للألوان
  Widget _buildColorLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // تنسيق القيم للمحاور (مقرب)
  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  // تنسيق القيم للعرض في الـ Tooltip (أكثر دقة)
  String _formatValueForDisplay(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)}K';
    } else {
      return value.toStringAsFixed(2);
    }
  }

  // دالة لحساب أعلى قيمة Y - مع مساحة كافية لظهور آخر رقم
  double _getMaxY(List<SalesCategory> displayCategories) {
    if (displayCategories.isEmpty) return 1000;

    // البحث عن أعلى قيمة بين الكميات والمبيعات
    double maxValue = 0;
    for (var category in displayCategories) {
      if (category.basicQty > maxValue) maxValue = category.basicQty;
      if (category.totCost > maxValue) maxValue = category.totCost;
    }

    // تقريب أفضل لأعلى قيمة
    double roundedMax;
    if (maxValue <= 10000) {
      roundedMax = ((maxValue / 2000).ceil() * 2000).toDouble();
    } else if (maxValue <= 100000) {
      roundedMax = ((maxValue / 10000).ceil() * 10000).toDouble();
    } else {
      roundedMax = ((maxValue / 50000).ceil() * 50000).toDouble();
    }

    // إضافة 30% مساحة إضافية لضمان ظهور أعلى رقم بالكامل
    return roundedMax * 1.3;
  }

  // حساب الفاصل الزمني للمحور Y
  double _getInterval(List<SalesCategory> displayCategories) {
    final maxY = _getMaxY(displayCategories);
    return maxY / 5; // تقسيم إلى 5 خطوط للوضوح
  }

  // دالة لإنشاء مجموعات الأعمدة - عمودين لكل تصنيف
  List<BarChartGroupData> _generateBarGroups(List<SalesCategory> displayCategories) {
    return List.generate(displayCategories.length, (index) {
      final category = displayCategories[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          // عمود الكمية
          BarChartRodData(
            toY: category.basicQty,
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.green,
                Colors.greenAccent,
              ],
            ),
            width: 18, // تقليل العرض قليلاً من 20 إلى 18
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(displayCategories),
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          // عمود المبيعات
          BarChartRodData(
            toY: category.totCost,
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.amber,
                Colors.amberAccent,
              ],
            ),
            width: 18, // تقليل العرض قليلاً من 20 إلى 18
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(displayCategories),
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ],
      );
    });
  }

  // عناوين المحور السفلي - نص عمودي مع تقصير أفضل
  Widget _bottomTitles(double value, TitleMeta meta, List<SalesCategory> displayCategories) {
    final index = value.toInt();
    if (index >= displayCategories.length) return const SizedBox.shrink();

    const style = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize:12, // تقليل حجم الخط أكثر
    );

    String categoryName = displayCategories[index].categoryName;

    // تقصير النص بشكل أفضل
    if (categoryName.length > 20) {
      categoryName = categoryName.substring(0, 8);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4, // تقليل المسافة
      child: Container(
        constraints: const BoxConstraints(maxWidth: 120), // تقليل العرض المسموح
        child: Text(
          categoryName,
          style: style,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // عناوين المحور الصادي
  Widget _leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white70,
      fontWeight: FontWeight.w500,
      fontSize: 9,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(_formatValue(value), style: style),
    );
  }
}