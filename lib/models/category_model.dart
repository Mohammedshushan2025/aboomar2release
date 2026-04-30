class CategoryModel {
  final int code;
  final String nameA;
  final String? nameE;

  CategoryModel({
    required this.code,
    required this.nameA,
    this.nameE,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      code: _parseInt(json['code']),
      nameA: json['name_a']?.toString() ?? '',
      nameE: json['name_e']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name_a': nameA,
      'name_e': nameE,
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  @override
  String toString() {
    return 'CategoryModel(code: $code, nameA: $nameA, nameE: $nameE)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel &&
        other.code == code &&
        other.nameA == nameA &&
        other.nameE == nameE;
  }

  @override
  int get hashCode {
    return Object.hash(code, nameA, nameE);
  }
}