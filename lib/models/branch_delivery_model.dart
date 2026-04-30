class BranchDelivery {
  final String trnsDate;
  final String branchName;
  final double cashAmount;
  final double visaAmount;
  final double expensesAmount;
  final double total;

  BranchDelivery({
    required this.trnsDate,
    required this.branchName,
    required this.cashAmount,
    required this.visaAmount,
    required this.expensesAmount,
    required this.total,
  });

  factory BranchDelivery.fromJson(Map<String, dynamic> json) {
    return BranchDelivery(
      trnsDate: json['trns_date'] as String,
      branchName: json['name_a'] as String,
      cashAmount: (json['cash_amount'] ?? 0).toDouble(),
      visaAmount: (json['visa_amount'] ?? 0).toDouble(),
      expensesAmount: (json['expenses_amount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}