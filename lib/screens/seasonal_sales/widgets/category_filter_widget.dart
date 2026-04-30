
/*
import 'package:flutter/material.dart';
import 'package:aboomar/models/group_category_model.dart';

class CategoryFilterWidget extends StatelessWidget {
  final List<GroupCategory> categories;
  final int? selectedCategoryCode;
  final Function(int) onCategorySelected;

  const CategoryFilterWidget({
    super.key,
    required this.categories,
    required this.selectedCategoryCode,
    required this.onCategorySelected,
  });

  // دالة لاختيار أيقونة بناءً على اسم التصنيف (للتوضيح)
  IconData _getIconForCategory(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('تورت') || lowerName.contains('جاتوه')) return Icons.cake_outlined;
    if (lowerName.contains('غربي') || lowerName.contains('سواريه')) return Icons.star_border;
    if (lowerName.contains('كعك')) return Icons.cookie_outlined;
    if (lowerName.contains('شرقي')) return Icons.brightness_5_outlined;
    return Icons.bakery_dining_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // ارتفاع مناسب لعرض الشرائح
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.code == selectedCategoryCode;
          return GestureDetector(
            onTap: () => onCategorySelected(category.code),
            child: Container(
              width: 90, // عرض الشريحة
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getIconForCategory(category.name),
                    size: 32,
                    color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

 */

import 'package:flutter/material.dart';
import 'package:aboomar2release/models/group_category_model.dart';

class CategoryFilterWidget extends StatelessWidget {
  final List<GroupCategory> categories;
  final int? selectedCategoryCode;
  final Function(int) onCategorySelected;

  const CategoryFilterWidget({
    super.key,
    required this.categories,
    required this.selectedCategoryCode,
    required this.onCategorySelected,
  });

  // قائمة بألوان عصرية ومميزة
  final List<Color> _categoryColors = const [
    Color(0xFF4A90E2), // Vibrant Blue
    Color(0xFF50E3C2), // Aqua Green
    Color(0xFFB8E986), // Lime Green
    Color(0xFFF8E71C), // Bright Yellow
    Color(0xFFF5A623), // Orange
    Color(0xFFBD10E0), // Purple
    Color(0xFFD0021B), // Strong Red
    Color(0xFF417505), // Forest Green
    Color(0xFF9013FE), // Violet
    Color(0xFF7ED321), // Light Green
    Color(0xFF00A3A3), // Teal
    Color(0xFFE94E77), // Pink
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50, // تقليل ارتفاع الويدجت بشكل كبير
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.code == selectedCategoryCode;
          // استخدام الألوان بشكل متكرر إذا كان عدد التصنيفات أكبر من الألوان
          final chipColor = _categoryColors[index % _categoryColors.length];

          return GestureDetector(
            onTap: () => onCategorySelected(category.code),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300), // مدة الأنيميشن
              curve: Curves.easeInOut, // نوع الأنيميشن
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? chipColor : Colors.white,
                borderRadius: BorderRadius.circular(20), // شكل دائري أكثر
                border: Border.all(
                  color: isSelected ? chipColor.withOpacity(0.8) : Colors.grey.shade300,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: chipColor.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
                    : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  category.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}