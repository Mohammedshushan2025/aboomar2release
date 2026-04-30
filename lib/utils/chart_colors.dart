import 'package:flutter/material.dart';

class ChartColors {
  static const List<Color> pieChartColors = [
    Color(0xFF0293EE), // أزرق
    Color(0xFFF8B250), // برتقالي
    Color(0xFF845EC2), // بنفسجي
    Color(0xFF00D2FF), // سماوي
    Color(0xFF4E9F3D), // أخضر
    Color(0xFFFF6B6B), // أحمر
    Color(0xFFFFD93D), // أصفر
    Color(0xFF6BCF7F), // أخضر فاتح
    Color(0xFFFFB4A2), // وردي فاتح
    Color(0xFF95E1D3), // أخضر نعناعي
    Color(0xFFCE96FB), // بنفسجي فاتح
    Color(0xFFFF9A8B), // برتقالي فاتح
    Color(0xFF84FAB0), // أخضر ليموني
    Color(0xFFA8E6CF), // أخضر نعناعي فاتح
    Color(0xFFFFAB91), // برتقالي خوخي
  ];

  static Color getColorByIndex(int index) {
    return pieChartColors[index % pieChartColors.length];
  }

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFffecd2), Color(0xFFfcb69f)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}