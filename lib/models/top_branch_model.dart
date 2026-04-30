class TopBranch {
  final String name;
  final double total;

  TopBranch({required this.name, required this.total});

  factory TopBranch.fromJson(Map<String, dynamic> json) {
    return TopBranch(
      name: json['name_a'] as String,
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}