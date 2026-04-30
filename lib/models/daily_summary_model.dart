import 'package:flutter/foundation.dart';

class DailySummary {
  final double cashAmount;
  final double visaAmount;
  final double expensesAmount;
  final double total;

  DailySummary({
    required this.cashAmount,
    required this.visaAmount,
    required this.expensesAmount,
    required this.total,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    // التعامل مع القيم الفارغة أو غير الرقمية
    final cash = (json['cash_amount'] ?? 0).toDouble();
    final visa = (json['visa_amount'] ?? 0).toDouble();
    final expenses = (json['expenses_amount'] ?? 0).toDouble();
    final total = (json['total'] ?? 0).toDouble();

    return DailySummary(
      cashAmount: cash,
      visaAmount: visa,
      expensesAmount: expenses,
      total: total,
    );
  }

  // لإنشاء كائن فارغ في حالة عدم وجود بيانات
  factory DailySummary.empty() {
    return DailySummary(
        cashAmount: 0.0,
        visaAmount: 0.0,
        expensesAmount: 0.0,
        total: 0.0
    );
  }
}