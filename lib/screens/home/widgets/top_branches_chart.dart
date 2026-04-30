import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../models/top_branch_model.dart';

class TopBranchesChart extends StatelessWidget {
  final List<TopBranch> branches;
  const TopBranchesChart({super.key, required this.branches});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
                Color(0xFF1E3A8A), // أزرق داكن
                Color(0xFF3B82F6), // أزرق فاتح
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
                        l.translate("top_5_branches"),
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
                AspectRatio(
                  aspectRatio: 1.2, // تقليل النسبة لإعطاء مساحة أكبر للأسماء
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxY(),
                      minY: 0,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          tooltipRoundedRadius: 8,
                          tooltipPadding: const EdgeInsets.all(8),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            String branchName = branches[group.x.toInt()].name;
                            // عرض الرقم الدقيق بدون تقريب
                            String exactValue = branches[group.x.toInt()].total.toStringAsFixed(2);
                            return BarTooltipItem(
                              branchName,
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              children: <TextSpan>[
                                const TextSpan(text: '\n'),
                                TextSpan(
                                  text: exactValue,
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
                            getTitlesWidget: _bottomTitles,
                            reservedSize: 80, // زيادة المساحة للأسماء العمودية
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60, // زيادة المساحة
                            interval: _getInterval(),
                            getTitlesWidget: _leftTitles,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _generateBarGroups(),
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        drawVerticalLine: false,
                        horizontalInterval: _getInterval(),
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
                const SizedBox(height: 16),
                // إضافة legend لعرض أسماء الفروع كاملة
                _buildLegend(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بناء الـ Legend لعرض أسماء الفروع مع القيم الدقيقة
  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: branches.asMap().entries.map((entry) {
        int index = entry.key;
        TopBranch branch = entry.value;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.amberAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                branch.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${_formatValueForDisplay(branch.total)})',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      }).toList(),
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

  // تنسيق القيم للعرض في الـ Legend (أكثر دقة)
  String _formatValueForDisplay(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)}K';
    } else {
      return value.toStringAsFixed(2);
    }
  }

  // دالة لحساب أعلى قيمة Y - مع تقريب أفضل
  double _getMaxY() {
    if (branches.isEmpty) return 1000;
    final maxTotal = branches.map((b) => b.total).reduce((a, b) => a > b ? a : b);

    // تقريب أفضل لأعلى قيمة
    if (maxTotal <= 10000) {
      return ((maxTotal / 1000).ceil() * 1000).toDouble();
    } else if (maxTotal <= 100000) {
      return ((maxTotal / 5000).ceil() * 5000).toDouble();
    } else {
      return ((maxTotal / 10000).ceil() * 10000).toDouble();
    }
  }

  // حساب الفاصل الزمني للمحور Y - محسن لتقليل الازدحام أكثر
  double _getInterval() {
    final maxY = _getMaxY();

    // تقليل عدد التسميات في المحور Y أكثر
    if (maxY >= 100000) {
      return maxY / 4; // 4 خطوط فقط
    } else if (maxY >= 50000) {
      return maxY / 4; // 4 خطوط
    } else if (maxY >= 25000) {
      return maxY / 4; // 4 خطوط
    } else if (maxY >= 10000) {
      return maxY / 4; // 4 خطوط
    } else {
      return maxY / 3; // 3 خطوط للقيم الصغيرة
    }
  }

  // دالة لإنشاء مجموعات الأعمدة
  List<BarChartGroupData> _generateBarGroups() {
    return List.generate(branches.length, (index) {
      final branch = branches[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: branch.total,
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.amber,
                Colors.amberAccent,
              ],
            ),
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(),
              color: Colors.white.withOpacity(0.1),
            ),
          )
        ],
      );
    });
  }

  // عناوين المحور السفلي - عرض الأسماء كاملة بشكل عمودي
  Widget _bottomTitles(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index >= branches.length) return const SizedBox.shrink();

    const style = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );

    // عرض الاسم كاملاً مع تدوير
    String branchName = branches[index].name;

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Transform.rotate(
        angle: -0.7, // دوران أكثر للنص العمودي
        child: Container(
          constraints: const BoxConstraints(maxWidth: 60),
          child: Text(
            branchName,
            style: style,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  // عناوين المحور الصادي - محسنة لمنع التكرار والازدحام
  Widget _leftTitles(double value, TitleMeta meta) {
    // تجنب إظهار القيمة صفر
    if (value == 0) return const SizedBox.shrink();

    const style = TextStyle(
      color: Colors.white70,
      fontWeight: FontWeight.w500,
      fontSize: 9, // تصغير الخط أكثر
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(_formatValue(value), style: style),
    );
  }
}