/*
// مسار الملف: lib/services/auth_service.dart
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import '../utils/device_info_provider.dart';
import 'package:geolocator/geolocator.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final DeviceInfoProvider _deviceInfoProvider = DeviceInfoProvider();
  static const String _userKey = 'loggedInUser';

  Future<UserModel> login(String userCode, String password) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      throw Exception('noInternet');
    }

    final List<UserModel> allUsers = await _apiService.getAllUsers();

    UserModel? user;
    try {
      // إصلاح المقارنة - كلاهما String الآن
      user = allUsers.firstWhere(
            (u) => u.usersCode == userCode, // تم حذف toString()
      );
    } catch (e) {
      print('User not found for code: $userCode');
      print('Available users: ${allUsers.map((u) => u.usersCode).toList()}');
      throw Exception('userNotFound');
    }

    if (user.password != password) {
      print('Password mismatch for user: $userCode');
      throw Exception('invalidPassword');
    }

    await _saveUser(user);

    // لا ننتظر هذه الدالة، ستعمل في الخلفية
    _postActivity(user.usersCode);

    return user;
  }

  Future<void> _postActivity(String userCode) async {
    try {
      // جلب كل البيانات المطلوبة
      final ip = await _deviceInfoProvider.getIpAddress();
      final deviceId = await _deviceInfoProvider.getDeviceUniqueId();
      final osUser = await _deviceInfoProvider.getOsUser();

      // تصحيح التوقيت - إضافة ساعة واحدة للتوقيت المحلي
      final String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
          .format(DateTime.now().toUtc().add(Duration(hours: 1)));

      // جلب الموقع
      Position? position;
      try {
        position = await _deviceInfoProvider.determinePosition();
      } catch (e) {
        print("Could not get location: $e");
      }

      final Map<String, dynamic> loginData = {
        "users_code": userCode, // يبقى String كما هو
        "machine_ip": ip,
        "machine_mac": deviceId,
        "osuser": osUser,
        "contime": formattedDate,
        "latitude": position?.latitude,
        "longitude": position?.longitude,
      };

      print('Sending login data: $loginData');
      await _apiService.postLoginData(loginData);
      print('Login activity posted successfully!');

    } catch (e) {
      print("Could not post activity data: $e");
    }
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<UserModel?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString(_userKey);
    if (userData != null) {
      return UserModel.fromJson(json.decode(userData));
    }
    return null;
  }
}
*/
// مسار الملف: lib/services/auth_service.dart
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import '../utils/device_info_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'api_exceptions.dart'; // <-- استيراد ملف الأخطاء الجديد

class AuthService {
  final ApiService _apiService = ApiService();
  final DeviceInfoProvider _deviceInfoProvider = DeviceInfoProvider();
  static const String _userKey = 'loggedInUser';

  // الدالة الآن ترسل أخطاء مخصصة وواضحة
  Future<UserModel> login(String userCode, String password) async {
    try {
      final List<UserModel> allUsers = await _apiService.getAllUsers();

      UserModel? user;
      try {
        user = allUsers.firstWhere((u) => u.usersCode == userCode);
      } catch (e) {
        // خطأ منطقي: المستخدم غير موجود
        throw UserNotFoundException();
      }

      if (user.password != password) {
        // خطأ منطقي: كلمة المرور غير صحيحة
        throw InvalidPasswordException();
      }

      await _saveUser(user);
      _postActivity(user.usersCode);

      print("✅ تم تسجيل الدخول بنجاح للمستخدم: ${user.usersCode}");
      print("📌 الفلاجات الخاصة به:");
      print("- hideRevenueFlag: ${user.hideRevenueFlag}");
      print("- hideSalesDetailsFlag: ${user.hideSalesDetailsFlag}");
      print("- hideSeasonSalesFlag: ${user.hideSeasonSalesFlag}");

      return user;

    } on ApiException {
      // إذا كان الخطأ من نوعنا (مثل NoInternetException)، أعد إرساله كما هو
      rethrow;
    } catch (e) {
      // أي خطأ آخر غير متوقع
      throw ApiException('unexpectedError');
    }
  }

  Future<void> _postActivity(String userCode) async {
    try {
      final ip = await _deviceInfoProvider.getIpAddress();
      final deviceId = await _deviceInfoProvider.getDeviceUniqueId();
      final osUser = await _deviceInfoProvider.getOsUser();
      final String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
          .format(DateTime.now().toUtc().add(const Duration(hours: 1)));
      Position? position;
      try {
        position = await _deviceInfoProvider.determinePosition();
      } catch (e) {
        print("Could not get location: $e");
      }

      final Map<String, dynamic> loginData = {
        "users_code": userCode,
        "machine_ip": ip,
        "machine_mac": deviceId,
        "osuser": osUser,
        "contime": formattedDate,
        "latitude": position?.latitude,
        "longitude": position?.longitude,
      };

      await _apiService.postLoginData(loginData);
    } catch (e) {
      print("Could not post activity data: $e");
    }
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<UserModel?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString(_userKey);
    if (userData != null) {
      return UserModel.fromJson(json.decode(userData));
    }
    return null;
  }
}