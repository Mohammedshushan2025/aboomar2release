class SalesCategory {
  final double basicQty;
  final double totCost;
  final String startDate;
  final String countryCode;
  final String gategoryName;

  SalesCategory({
    required this.basicQty,
    required this.totCost,
    required this.startDate,
    required this.countryCode,
    required this.gategoryName,
  });

  factory SalesCategory.fromJson(Map<String, dynamic> json) {
    return SalesCategory(
      basicQty: (json['basic_qty'] ?? 0).toDouble(),
      totCost: (json['tot_cost'] ?? 0).toDouble(),
      startDate: json['start_date'] ?? '',
      countryCode: json['country_code'] ?? '',
      gategoryName: json['gategry_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'basic_qty': basicQty,
      'tot_cost': totCost,
      'start_date': startDate,
      'country_code': countryCode,
      'gategry_name': gategoryName,
    };
  }
}