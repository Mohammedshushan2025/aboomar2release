/*
// مسار الملف: lib/services/api_service.dart
import 'dart:convert';
import 'package:aboomar/models/branch_delivery_model.dart';
import 'package:aboomar/models/group_category_model.dart';
import 'package:aboomar/models/sales_category_model.dart';
import 'package:aboomar/models/seasonal_sales_model.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:intl/intl.dart';
import '../models/daily_summary_model.dart';
import '../models/top_branch_model.dart';
import '../models/revenue_day_model.dart';

class ApiService {
  final String _baseUrl = 'http://49.12.171.232:7003/ords/ascon_scai/Sa_Api';

  // دالة مساعدة لتنسيق التاريخ بالشكل المطلوب
  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  Future<DailySummary> getDailyPerformance(DateTime date) async {
    final url = '$_baseUrl/get_all_devlivery_day?from_date=${_formatDate(date)}';
    print('📡 API Call: $url');

    try {
      final response = await http.get(Uri.parse(url));
      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body.length > 500 ? response.body.substring(0, 500) + "..." : response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          print('✅ DailySummary data found: ${data['items'][0]}');
          return DailySummary.fromJson(data['items'][0]);
        }
        print('⚠️ No daily summary data found, returning empty object');
        return DailySummary.empty();
      } else {
        print('❌ Daily performance API error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load daily performance: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Daily performance API exception: $e');
      rethrow;
    }
  }

  Future<List<TopBranch>> getTop5Branches(DateTime date) async {
    final url = '$_baseUrl/get_top_5_branches_revenu?from_date=${_formatDate(date)}';
    print('📡 API Call: $url');

    try {
      final response = await http.get(Uri.parse(url));
      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body.length > 500 ? response.body.substring(0, 500) + "..." : response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        print('✅ Top branches data found: ${items.length} branches');
        return items.map((item) => TopBranch.fromJson(item)).toList();
      } else {
        print('❌ Top branches API error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load top branches: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Top branches API exception: $e');
      rethrow;
    }
  }

  Future<List<RevenueDay>> getRevenueLast7Days() async {
    final url = '$_baseUrl/get_lat_revenu_7_days';
    print('📡 API Call: $url');

    try {
      final response = await http.get(Uri.parse(url));
      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body.length > 500 ? response.body.substring(0, 500) + "..." : response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        print('✅ Revenue days data found: ${items.length} days');
        return items.map((item) => RevenueDay.fromJson(item)).toList();
      } else {
        print('❌ Revenue days API error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load revenue trend: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Revenue days API exception: $e');
      rethrow;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    final url = '$_baseUrl/get_access_user_info';
    print('📡 API Call: $url');

    try {
      final response = await http.get(Uri.parse(url));
      print('📡 Users Response Status: ${response.statusCode}');
      print('📡 Users Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        print('✅ Users data found: ${items.length} users');
        return items.map((item) => UserModel.fromJson(item)).toList();
      } else {
        print('❌ Users API error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Users API exception: $e');
      rethrow;
    }
  }

  Future<void> postLoginData(Map<String, dynamic> loginData) async {
    final url = 'http://49.12.171.232:7003/ords/ascon_scai/hrapi/ACCESSINFO';
    print('📡 Login API Call: $url');
    print('📡 Login Data: $loginData');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(loginData),
      );

      print('📡 Login Response Status: ${response.statusCode}');
      print('📡 Login Response Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('❌ Failed to post login data. Status: ${response.statusCode}');
        print('❌ Response Body: ${response.body}');
      } else {
        print('✅ Login activity posted successfully!');
      }
    } catch (e) {
      print('❌ Login API exception: $e');
      rethrow;
    }
  }

  Future<List<BranchDelivery>> getBranchDeliveries(DateTime date) async {
    final url = '$_baseUrl/pos_delivery_day_store?store_code=null&from_date=${_formatDate(date)}';
    print('📡 API Call: $url');

    try {
      final response = await http.get(Uri.parse(url));
      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body.length > 500 ? response.body.substring(0, 500) + "..." : response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        if (items.isEmpty) {
          print('⚠️ No branch deliveries data found');
          return [];
        }
        print('✅ Branch deliveries data found: ${items.length} deliveries');
        return items.map((item) => BranchDelivery.fromJson(item)).toList();
      } else {
        print('❌ Branch deliveries API error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load branch deliveries: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Branch deliveries API exception: $e');
      rethrow;
    }
  }
  // دالة الحصول على Headers
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'charset': 'utf-8',
    };
  }
  Future<List<SalesCategory>> getSalesCategories(DateTime date) async {
    try {
      final String formattedDate = DateFormat('dd-MM-yyyy').format(date);

      final String url = '$_baseUrl/get_sales_category_without_bal?from_date=$formattedDate&to_date=$formattedDate';

      print('🔗 استدعاء API فئات المبيعات: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final SalesCategoryResponse categoryResponse = SalesCategoryResponse.fromJson(jsonResponse);

        print('✅ تم تحميل ${categoryResponse.items.length} فئة مبيعات');
        return categoryResponse.items;
      } else {
        print('❌ خطأ في استدعاء فئات المبيعات: ${response.statusCode}');
        throw Exception('فشل في تحميل فئات المبيعات: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطأ في getSalesCategories: $e');
      throw Exception('خطأ في تحميل فئات المبيعات: $e');
    }
  }


  // دالة لجلب قائمة التصنيفات
  Future<List<GroupCategory>> getGroupCategories() async {
    final response = await http.get(
      Uri.parse('http://49.12.171.232:7003/ords/ascon_scai/Sa_Api/get_group_category'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> items = data['items'];
      return items.map((item) => GroupCategory.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load group categories');
    }
  }

  // دالة لجلب بيانات المبيعات لتصنيف وتاريخ محدد
  Future<List<SeasonalSalesData>> getSeasonalSales({
    required DateTime date,
    required int categoryCode,
  }) async {
    final formattedDate = DateFormat('dd-MM-yyyy').format(date);
    final url =
        'http://49.12.171.232:7003/ords/ascon_scai/Sa_Api/get_pos_sales_category?store_code=null&from_date=$formattedDate&to_date=$formattedDate&country_code=$categoryCode';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> items = data['items'];
      return items.map((item) => SeasonalSalesData.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load sales data for category $categoryCode');
    }
  }


  // إضافة هذه الدالة في ApiService class

  Future<List<SalesCategory>> getSalesCategoriesDetailed(DateTime selectedDate) async {
    try {
      final formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);

      final response = await http.get(
        Uri.parse('$_baseUrl/get_sales_category_without_bal?from_date=$formattedDate&to_date=$formattedDate'),
      );

      print('🔄 Sales Categories API Response Status: ${response.statusCode}');
      print('📊 Sales Categories API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];

        List<SalesCategory> categories = items
            .map((item) => SalesCategory.fromJson(item))
            .toList();

        print('✅ تم جلب ${categories.length} تصنيف بنجاح');
        return categories;
      } else {
        print('❌ خطأ في API: ${response.statusCode}');
        throw Exception('فشل في جلب بيانات التصنيفات: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطأ في getSalesCategoriesDetailed: $e');
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }
}



*/
// مسار الملف: lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:aboomar2release/models/branch_delivery_model.dart';
import 'package:aboomar2release/models/group_category_model.dart';
import 'package:aboomar2release/models/sales_category_model.dart';
import 'package:aboomar2release/models/seasonal_sales_model.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:intl/intl.dart';
import '../models/daily_summary_model.dart';
import '../models/top_branch_model.dart';
import '../models/revenue_day_model.dart';
import 'api_exceptions.dart'; // <-- استيراد ملف الأخطاء الجديد
import '../utils/api_logger.dart'; // <-- مراقب الـ API (للتطوير فقط)

class ApiService {
  final String _baseUrl = 'http://49.12.171.232:7003/ords/ascon_scai/Sa_Br2_Api';
  final Duration _timeoutDuration = const Duration(seconds: 30);

  // دالة مساعدة لتنسيق التاريخ
  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  // دالة مساعدة لمعالجة استجابات الـ HTTP والأخطاء
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else if (response.statusCode >= 500) {
      throw ServerException();
    } else {
      // يمكن إضافة معالجة لأكواد أخرى مثل 404, 401, etc.
      throw ApiException('unexpectedError');
    }
  }

  // دالة مساعدة لتغليف طلبات GET
  Future<dynamic> _get(String url) async {
    // ── تسجيل الطلب (للمراقبة فقط، لا يؤثر على اللوجيك) ──
    final logId = ApiLogger.instance.logRequest(method: 'GET', url: url);
    final stopwatch = Stopwatch()..start();
    // ──────────────────────────────────────────────────────
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeoutDuration);
      // ── تسجيل الاستجابة ──
      stopwatch.stop();
      ApiLogger.instance.logResponse(
        id: logId,
        statusCode: response.statusCode,
        responseBody: response.body,
        duration: stopwatch.elapsed,
      );
      // ─────────────────────
      return _handleResponse(response);
    } on SocketException {
      stopwatch.stop();
      ApiLogger.instance.logError(id: logId, error: 'SocketException: No Internet', duration: stopwatch.elapsed);
      throw NoInternetException();
    } on TimeoutException {
      stopwatch.stop();
      ApiLogger.instance.logError(id: logId, error: 'TimeoutException: Request timed out', duration: stopwatch.elapsed);
      throw TimeoutException();
    } catch (e) {
      // إذا كان الخطأ من نوعنا المخصص، أعد إرساله، وإلا أرسل خطأ خادم عام
      if (e is ApiException) {
        stopwatch.stop();
        ApiLogger.instance.logError(id: logId, error: e.toString(), duration: stopwatch.elapsed);
        rethrow;
      }
      stopwatch.stop();
      ApiLogger.instance.logError(id: logId, error: e.toString(), duration: stopwatch.elapsed);
      throw ServerException();
    }
  }

  Future<DailySummary> getDailyPerformance(DateTime date) async {
    final url = '$_baseUrl/get_all_devlivery_day?from_date=${_formatDate(date)}';
    final data = await _get(url);
    if (data['items'] != null && data['items'].isNotEmpty) {
      return DailySummary.fromJson(data['items'][0]);
    }
    return DailySummary.empty();
  }

  Future<List<TopBranch>> getTop5Branches(DateTime date) async {
    final url = '$_baseUrl/get_top_5_branches_revenu?from_date=${_formatDate(date)}';
    final data = await _get(url);
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) => TopBranch.fromJson(item)).toList();
  }

  Future<List<RevenueDay>> getRevenueLast7Days() async {
    final url = '$_baseUrl/get_lat_revenu_7_days';
    final data = await _get(url);
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) => RevenueDay.fromJson(item)).toList();
  }

  Future<List<UserModel>> getAllUsers() async {
    final url = '$_baseUrl/get_access_user_info';
    final data = await _get(url);
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) => UserModel.fromJson(item)).toList();
  }

  Future<void> postLoginData(Map<String, dynamic> loginData) async {
    final url = 'http://49.12.171.232:7003/ords/ascon_scai/hrapi/ACCESSINFO';
    // ── تسجيل الطلب (للمراقبة فقط) ──
    final logId = ApiLogger.instance.logRequest(
      method: 'POST',
      url: url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(loginData),
    );
    final stopwatch = Stopwatch()..start();
    // ─────────────────────────────────
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(loginData),
      ).timeout(_timeoutDuration);
      // ── تسجيل الاستجابة ──
      stopwatch.stop();
      ApiLogger.instance.logResponse(
        id: logId,
        statusCode: response.statusCode,
        responseBody: response.body,
        duration: stopwatch.elapsed,
      );
      // ─────────────────────
      // لا نتحقق من الاستجابة هنا لأنها تعمل في الخلفية
    } catch (e) {
      // نطبع الخطأ فقط ولا نوقِف التطبيق
      stopwatch.stop();
      ApiLogger.instance.logError(id: logId, error: e.toString(), duration: stopwatch.elapsed);
      print("Could not post activity data: $e");
    }
  }

  Future<List<BranchDelivery>> getBranchDeliveries(DateTime date) async {
    final url = '$_baseUrl/pos_delivery_day_store?store_code=null&from_date=${_formatDate(date)}';
    final data = await _get(url);
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) => BranchDelivery.fromJson(item)).toList();
  }

  Future<List<SalesCategory>> getSalesCategories(DateTime date) async {
    final url = '$_baseUrl/get_sales_category_without_bal?from_date=${_formatDate(date)}&to_date=${_formatDate(date)}';
    final data = await _get(url);
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) => SalesCategory.fromJson(item)).toList();
  }

  Future<List<GroupCategory>> getGroupCategories() async {
    final url = '$_baseUrl/get_group_category';
    final data = await _get(url);
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) => GroupCategory.fromJson(item)).toList();
  }

  Future<List<SeasonalSalesData>> getSeasonalSales({required DateTime date, required int categoryCode}) async {
    final url = '$_baseUrl/get_pos_sales_category?store_code=null&from_date=${_formatDate(date)}&to_date=${_formatDate(date)}&country_code=$categoryCode';
    final data = await _get(url);
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) => SeasonalSalesData.fromJson(item)).toList();
  }

  Future<List<SalesCategory>> getSalesCategoriesDetailed(DateTime selectedDate) async {
    // هذه الدالة مكررة، يمكن استخدام getSalesCategories بدلاً منها
    return getSalesCategories(selectedDate);
  }

  // ============================================================
  // APIs جديدة لشاشة "مبيعات الموسم - إجمالي"
  // ============================================================

  Future<List<GroupCategory>> getGroupCategories2() async {
    final url = '$_baseUrl/get_group_category2';
    print('📡 API Call (GroupCategories2): $url');
    final data = await _get(url);
    final List<dynamic> items = data['items'] ?? [];
    if (items.isEmpty) {
      print('⚠️ GroupCategories2: No data found');
    } else {
      print('✅ GroupCategories2 Data found: ${items.length} items');
    }
    return items.map((item) => GroupCategory.fromJson(item)).toList();
  }

  Future<List<SeasonalSalesData>> getSeasonalSalesTotal({
    required DateTime date,
    required int kindCode,
  }) async {
    final url =
        '$_baseUrl/get_pos_sales_category2?store_code=null&from_date=${_formatDate(date)}&to_date=${_formatDate(date)}&kind_code=$kindCode';
    print('📡 API Call (SeasonalSalesTotal): $url');
    final data = await _get(url);
    final List<dynamic> items = data['items'] ?? [];
    if (items.isEmpty) {
      print('⚠️ SeasonalSalesTotal: No data found for kindCode=$kindCode and date=${_formatDate(date)}');
    } else {
      print('✅ SeasonalSalesTotal Data found: ${items.length} items');
    }
    return items.map((item) => SeasonalSalesData.fromJson(item)).toList();
  }

}