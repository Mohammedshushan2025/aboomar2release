// مسار الملف: lib/models/user_model.dart

class UserModel {
  final String usersCode;
  final String password;
  final String empName;
  final String? empNameE; // قد تكون القيمة null
  final String? jobDesc;
  final String? jobDescE;
  final String gender;
  final int hideRevenueFlag;
  final int hideSalesDetailsFlag;
  final int hideSeasonSalesFlag;

  UserModel({
    required this.usersCode,
    required this.password,
    required this.empName,
    this.empNameE,
    this.jobDesc,
    this.jobDescE,
    required this.gender,
    required this.hideRevenueFlag,
    required this.hideSalesDetailsFlag,
    required this.hideSeasonSalesFlag,
  });

  // دالة لإنشاء كائن UserModel من JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      usersCode: json['users_code'],
      password: json['password'],
      empName: json['emp_name'],
      empNameE: json['emp_name_e'],
      jobDesc: json['job_desc'],
      jobDescE: json['job_desc_e'],
      gender: json['gender'],
      hideRevenueFlag: _parseInt(json['hide_revenue_flag']),
      hideSalesDetailsFlag: _parseInt(json['hide_sales_details_flag']),
      hideSeasonSalesFlag: _parseInt(json['hide_season_sales_flag']),
    );
  }

  // دالة مساعدة لتحويل القيمة إلى رقم سواء كانت نصاً أو رقماً
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // دالة لتحويل الكائن إلى JSON (مفيدة لحفظ البيانات)
  Map<String, dynamic> toJson() {
    return {
      'users_code': usersCode,
      'password': password,
      'emp_name': empName,
      'emp_name_e': empNameE,
      'job_desc': jobDesc,
      'job_desc_e': jobDescE,
      'gender': gender,
      'hide_revenue_flag': hideRevenueFlag,
      'hide_sales_details_flag': hideSalesDetailsFlag,
      'hide_season_sales_flag': hideSeasonSalesFlag,
    };
  }
}
