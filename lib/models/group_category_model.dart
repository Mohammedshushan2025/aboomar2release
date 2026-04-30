class GroupCategory {
  final int code;
  final String name;

  GroupCategory({required this.code, required this.name});

  factory GroupCategory.fromJson(Map<String, dynamic> json) {
    return GroupCategory(
      code: json['code'],
      // استخدام name_a دائماً كما طلبت
      name: json['name_a'] ?? 'Unnamed Category',
    );
  }
}