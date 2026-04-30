class RevenueDay {
  final DateTime date;
  final double totalRevenue;

  RevenueDay({required this.date, required this.totalRevenue});

  factory RevenueDay.fromJson(Map<String, dynamic> json) {
    return RevenueDay(
      date: DateTime.parse(json['revenue_date']),
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
    );
  }
}