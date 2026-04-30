
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../app_localizations.dart';
import '../../../models/sales_category_model.dart';
import '../../../utils/chart_colors.dart';
import 'dart:math' as math;

class SalesPieChartWidget extends StatefulWidget {
  final List<SalesCategory> categories;

  const SalesPieChartWidget({
    Key? key,
    required this.categories,
  }) : super(key: key);

  @override
  State<SalesPieChartWidget> createState() => _SalesPieChartWidgetState();
}

class _SalesPieChartWidgetState extends State<SalesPieChartWidget>
    with TickerProviderStateMixin {
  int touchedIndex = -1;
  AnimationController? _animationController;
  Animation<double>? _animation;
  late ScrollController _scrollController; // إضافة ScrollController

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(); // تهيئة ScrollController
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );
    _animationController!.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // تنظيف ScrollController
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (widget.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final double totalCost = widget.categories.fold(0, (sum, category) => sum + category.totCost);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF8FAFC),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isArabic, totalCost),
          _buildModernChart(totalCost, isArabic),
        ],
      ),
    );
  }
// استبدل هذه الدالة بالكامل في ملفك
  Widget _buildHeader(BuildContext context, bool isArabic, double totalCost) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667eea),
            const Color(0xFF764ba2),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // السطر العلوي الذي يحتوي على الأيقونة والعنوان
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.donut_small,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  isArabic ? 'إجمالي المبيعات حسب الفئات' : 'Total Sales By Categories',
                  //  👇-- هذا هو التعديل الأساسي --👇
                  textScaler: TextScaler.linear(1.0),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // المبلغ الإجمالي في المنتصف
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _formatCurrency(totalCost, isArabic),
                //  👇-- وهذا أيضًا --👇
                textScaler: TextScaler.linear(1.0),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF667eea),
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildModernChart(double totalCost, bool isArabic) {
    return LayoutBuilder(
      builder: (context, constraints) {
// Use the new chart with labels for wide screens
        if (constraints.maxWidth > 600) {
          return _buildWideLayout(totalCost, isArabic);
        } else {
// Use the original chart for narrow screens
          return _buildNarrowLayout(totalCost, isArabic);
        }
      },
    );
  }

  Widget _buildWideLayout(double totalCost, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
// Use the new chart with labels
          Expanded(
            flex: 3, // Give more space for the chart and its labels
            child: Container(
              height: 300,
              child: _buildEnhancedDonutChartWithLabels(isArabic),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: Container(
              height: 300,
              child: _buildScrollableLegend(totalCost, isArabic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(double totalCost, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            height: 280,
            child: _buildEnhancedDonutChart(isArabic),
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            child: _buildScrollableLegend(totalCost, isArabic),
          ),
        ],
      ),
    );
  }

// This is the original chart for narrow screens (no labels)
  Widget _buildEnhancedDonutChart(bool isArabic) {
    final double totalCost = widget.categories.fold(0, (sum, category) => sum + category.totCost);

    if (_animation == null) {
      return Container(
        height: 240,
        child: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFF667eea),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation!,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 80, // Increased for a modern look
                sections: _createEnhancedSections(totalCost, isArabic, withLabels: false),
                startDegreeOffset: -90 + (360 * (1 - _animation!.value)),
              ),
            ),
            _buildChartCenter(totalCost, isArabic),
          ],
        );
      },
    );
  }

// ✨ NEW ✨: Chart with connector lines and labels for wide screens
  Widget _buildEnhancedDonutChartWithLabels(bool isArabic) {
    final double totalCost = widget.categories.fold(0, (sum, category) => sum + category.totCost);

    if (_animation == null) {
      return Container(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(color: const Color(0xFF667eea)),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation!,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: _createEnhancedSections(totalCost, isArabic, withLabels: true),
                startDegreeOffset: -90,
              ),
            ),
            _buildChartCenter(totalCost, isArabic),
// Add the labels and lines on top
            ..._buildCategoryLabels(totalCost, isArabic, 300),
          ],
        );
      },
    );
  }

// Modified to handle labels conditionally
  List<PieChartSectionData> _createEnhancedSections(double totalCost, bool isArabic, {required bool withLabels}) {
    final animationValue = _animation?.value ?? 1.0;
    return widget.categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final isTouched = index == touchedIndex;
      final percentage = (category.totCost / totalCost * 100);

// Don't show percentage inside slice if we're showing external labels
      final title = withLabels ? '' : (percentage > 5 ? '${percentage.toStringAsFixed(1)}%' : '');

      return PieChartSectionData(
        color: ChartColors.getColorByIndex(index),
        value: category.totCost * animationValue,
        title: title,
        radius: isTouched ? 45 : 35,
        titleStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();
  }

// ✨ NEW ✨: Function to build the labels and connector lines
  List<Widget> _buildCategoryLabels(double totalCost, bool isArabic, double containerSize) {
    List<Widget> labels = [];
    double currentAngle = -90; // Start from the top
    final animationValue = _animation?.value ?? 1.0;

    for (int i = 0; i < widget.categories.length; i++) {
      final category = widget.categories[i];
      final percentage = (category.totCost / totalCost * 100) * animationValue;
      final sweepAngle = (percentage / 100) * 360;

// Skip labels for very small categories to avoid clutter
      if (percentage < 3) {
        currentAngle += sweepAngle;
        continue;
      }

      final midAngle = currentAngle + (sweepAngle / 2);
      final radians = (midAngle * math.pi) / 180;

      final chartCenter = containerSize / 2;
      final pieRadius = 60; // centerSpaceRadius
      final lineStartRadius = pieRadius + 35; // section radius
      final lineEndRadius = lineStartRadius + 30;
      final labelRadius = lineEndRadius + 15;

      final lineStartX = chartCenter + (lineStartRadius * math.cos(radians));
      final lineStartY = chartCenter + (lineStartRadius * math.sin(radians));
      final lineEndX = chartCenter + (lineEndRadius * math.cos(radians));
      final lineEndY = chartCenter + (lineEndRadius * math.sin(radians));
      final labelX = chartCenter + (labelRadius * math.cos(radians));
      final labelY = chartCenter + (labelRadius * math.sin(radians));

// Add the connector line
      labels.add(
        Positioned.fill(
          child: CustomPaint(
            painter: ConnectorLinePainter(
              color: ChartColors.getColorByIndex(i),
              start: Offset(lineStartX, lineStartY),
              end: Offset(lineEndX, lineEndY),
            ),
          ),
        ),
      );

// Add the label widget
      labels.add(
        Positioned(
          left: labelX - 40, // Adjust position based on label width
          top: labelY - 15, // Adjust position based on label height
          child: _buildCategoryLabel(category, i, totalCost),
        ),
      );

      currentAngle += sweepAngle;
    }

    return labels;
  }

// ✨ NEW ✨: Helper widget for a single category label
  Widget _buildCategoryLabel(SalesCategory category, int index, double totalCost) {
    final percentage = (category.totCost / totalCost * 100);
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            category.categoryName,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: ChartColors.getColorByIndex(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCenter(double totalCost, bool isArabic) {
// This function remains the same as your original code
    return Container(
      width: 150, // Increased size
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white,
            const Color(0xFFF8FAFC),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            color: const Color(0xFF667eea),
            size: 24, // Increased size
          ),
          const SizedBox(height: 4),
          Text(
            isArabic ? 'الإجمالي' : 'Total',
            style: TextStyle(
              fontSize: 14, // Increased size
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            _formatCurrency(totalCost, isArabic, compact: true),
            style: TextStyle(
              fontSize: 18, // Increased size
              fontWeight: FontWeight.bold,
              color: const Color(0xFF667eea),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableLegend(double totalCost, bool isArabic) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.list_alt,
                  color: const Color(0xFF667eea),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'تفاصيل الفئات' : 'Category Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              controller: _scrollController, // إضافة ScrollController
              thumbVisibility: true,
              child: ListView.separated(
                controller: _scrollController, // إضافة ScrollController للـ ListView أيضاً
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: widget.categories.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _buildLegendItem(
                      widget.categories[index],
                      index,
                      totalCost,
                      isArabic
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(SalesCategory category, int index, double totalCost, bool isArabic) {
// This function remains the same as your original code
    final percentage = (category.totCost / totalCost * 100);
    final isSelected = index == touchedIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected
            ? ChartColors.getColorByIndex(index).withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? ChartColors.getColorByIndex(index)
              : Colors.grey.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: ChartColors.getColorByIndex(index).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : [],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            touchedIndex = touchedIndex == index ? -1 : index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: ChartColors.getColorByIndex(index),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: ChartColors.getColorByIndex(index).withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.categoryName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected
                          ? ChartColors.getColorByIndex(index)
                          : const Color(0xFF2D3748),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatCurrency(category.totCost, isArabic),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: ChartColors.getColorByIndex(index).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: ChartColors.getColorByIndex(index),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount, bool isArabic, {bool compact = false}) {
// This function remains the same as your original code
    if (compact) {
      return NumberFormat.compact(locale: isArabic ? 'ar' : 'en').format(amount);
    }
    final formatter = NumberFormat('#,##0.##', isArabic ? 'ar' : 'en');
    final formattedAmount = formatter.format(amount);
    return isArabic ? '$formattedAmount ج.م' : 'EGP $formattedAmount';
  }
}

// ✨ NEW ✨: Custom Painter for the connector lines
class ConnectorLinePainter extends CustomPainter {
  final Color color;
  final Offset start;
  final Offset end;

  ConnectorLinePainter({
    required this.color,
    required this.start,
    required this.end,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);

    canvas.drawPath(path, paint);

    canvas.drawCircle(end, 3, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}