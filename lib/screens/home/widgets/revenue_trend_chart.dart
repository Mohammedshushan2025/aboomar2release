import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app_localizations.dart';
import '../../../models/revenue_day_model.dart';

class RevenueTrendChart extends StatelessWidget {
  final List<RevenueDay> revenues;
  const RevenueTrendChart({super.key, required this.revenues});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
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
                        Icons.trending_up,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.translate("revenue_trend_last_7_days"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getTotalRevenueText(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 280, // زيادة الارتفاع لاستيعاب التواريخ العمودية
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        drawHorizontalLine: true,
                        horizontalInterval: _getHorizontalInterval(),
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.white.withOpacity(0.1),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60, // زيادة المساحة المحجوزة
                            interval: _getHorizontalInterval(),
                            getTitlesWidget: (value, meta) => _leftTitleWidgets(value, meta),
                          ),
                        ),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60, // زيادة المساحة للتواريخ العمودية
                            interval: 1,
                            getTitlesWidget: (value, meta) => _bottomTitleWidgets(value, meta, locale),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      lineBarsData: [_lineBarData()],
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          tooltipRoundedRadius: 8,
                          tooltipPadding: const EdgeInsets.all(8),
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final revenue = revenues[spot.x.toInt()];
                              final dayName = DateFormat('EEEE', 'ar').format(revenue.date);
                              final dateFormat = DateFormat('dd/MM/yyyy', 'ar').format(revenue.date);
                              // عرض الرقم الدقيق بدون تقريب
                              final exactValue = revenue.totalRevenue.toStringAsFixed(2);
                              return LineTooltipItem(
                                '$dayName\n$dateFormat\n$exactValue',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              );
                            }).toList();
                          },
                        ),
                        handleBuiltInTouches: true,
                        touchSpotThreshold: 30,
                      ),
                      minX: 0,
                      maxX: (revenues.length - 1).toDouble(),
                      minY: 0,
                      maxY: _getMaxY(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // إضافة ملخص سريع
                _buildSummary(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بناء ملخص سريع للبيانات
  Widget _buildSummary() {
    if (revenues.isEmpty) return const SizedBox.shrink();

    final total = revenues.fold(0.0, (sum, item) => sum + item.totalRevenue);
    final average = total / revenues.length;
    final highest = revenues.reduce((a, b) => a.totalRevenue > b.totalRevenue ? a : b);
    final lowest = revenues.reduce((a, b) => a.totalRevenue < b.totalRevenue ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('المتوسط', _formatValueForSummary(average), Icons.analytics),
          _buildSummaryItem('أعلى', _formatValueForSummary(highest.totalRevenue), Icons.trending_up),
          _buildSummaryItem('أقل', _formatValueForSummary(lowest.totalRevenue), Icons.trending_down),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // نص إجمالي الإيرادات
  String _getTotalRevenueText() {
    if (revenues.isEmpty) return '';
    final total = revenues.fold(0.0, (sum, item) => sum + item.totalRevenue);
    return 'إجمالي: ${_formatValueForSummary(total)}';
  }

  // تنسيق القيم للمحاور والملخص (مقرب)
  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  // تنسيق القيم للملخص (أكثر دقة)
  String _formatValueForSummary(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(2);
    }
  }

  // حساب أعلى قيمة Y
  double _getMaxY() {
    if (revenues.isEmpty) return 1000;
    final maxRevenue = revenues.map((r) => r.totalRevenue).reduce((a, b) => a > b ? a : b);
    return (maxRevenue * 1.2).ceilToDouble();
  }

  // حساب الفاصل الزمني للمحور Y - تحسين لتقليل الازدحام
  double _getHorizontalInterval() {
    final maxY = _getMaxY();

    // تقليل عدد الخطوط لتجنب الازدحام
    if (maxY >= 500000) return maxY / 4; // 4 خطوط فقط
    if (maxY >= 100000) return maxY / 5; // 5 خطوط
    if (maxY >= 50000) return 10000;
    if (maxY >= 10000) return 5000;
    if (maxY >= 5000) return 1000;
    return maxY / 4; // للقيم الصغيرة، قسمة على 4
  }

  // ويدجت لعناوين المحور السفلي - عرض التاريخ كاملاً بشكل عمودي
  Widget _bottomTitleWidgets(double value, TitleMeta meta, String locale) {
    const style = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 10,
        color: Colors.white70
    );

    int index = value.toInt();
    if (index < 0 || index >= revenues.length) return const SizedBox.shrink();

    // عرض اسم اليوم والتاريخ كاملاً
    String dayName = DateFormat('E', 'ar').format(revenues[index].date);
    String fullDate = DateFormat('dd/MM', 'ar').format(revenues[index].date);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Transform.rotate(
        angle: -0.5, // دوران طفيف لتجنب التداخل
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayName,
              style: style.copyWith(fontSize: 9),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              fullDate,
              style: style.copyWith(fontSize: 8),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت لعناوين المحور الصادي - تحسين التنسيق
  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 9, // تصغير الخط
      color: Colors.white70,
    );

    // إخفاء القيمة صفر لتقليل الازدحام
    if (value == 0) return const SizedBox.shrink();

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4, // تقليل المسافة
      child: Text(
        _formatValue(value),
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  // دالة لإنشاء بيانات الخط البياني
  LineChartBarData _lineBarData() {
    final spots = List.generate(revenues.length, (index) {
      return FlSpot(index.toDouble(), revenues[index].totalRevenue);
    });

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      gradient: const LinearGradient(
        colors: [
          Color(0xFF00E5FF),
          Color(0xFF0091EA),
        ],
      ),
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 6,
            color: Colors.white,
            strokeWidth: 3,
            strokeColor: const Color(0xFF0091EA),
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF00E5FF).withOpacity(0.3),
            const Color(0xFF0091EA).withOpacity(0.1),
          ],
        ),
      ),
      shadow: const Shadow(
        color: Colors.black26,
        offset: Offset(0, 2),
        blurRadius: 4,
      ),
    );
  }
}