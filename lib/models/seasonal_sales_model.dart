class SeasonalSalesData {
  final String branchName;
  final double quantity;
  final double totalCost;
  final double balance;

  SeasonalSalesData({
    required this.branchName,
    required this.quantity,
    required this.totalCost,
    required this.balance,
  });

  factory SeasonalSalesData.fromJson(Map<String, dynamic> json) {
    return SeasonalSalesData(
      branchName: json['store_name'] ?? 'Unknown Branch',
      quantity: (json['basic_qty'] ?? 0.0).toDouble(),
      totalCost: (json['tot_cost'] ?? 0.0).toDouble(),
      balance: (json['bal'] ?? 0.0).toDouble(),
    );
  }
}