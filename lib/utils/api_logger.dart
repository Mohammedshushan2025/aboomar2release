// lib/utils/api_logger.dart
// نظام تتبع الـ API calls - للتطوير فقط، لا يؤثر على أي لوجيك

class ApiLogEntry {
  final String id;
  final DateTime timestamp;
  final String method;
  final String url;
  final Map<String, String>? requestHeaders;
  final String? requestBody;
  final int? statusCode;
  final String? responseBody;
  final String? error;
  final Duration? duration;

  ApiLogEntry({
    required this.id,
    required this.timestamp,
    required this.method,
    required this.url,
    this.requestHeaders,
    this.requestBody,
    this.statusCode,
    this.responseBody,
    this.error,
    this.duration,
  });

  bool get isSuccess => statusCode != null && statusCode! >= 200 && statusCode! < 300;
  bool get isError => error != null || (statusCode != null && statusCode! >= 400);
  bool get isPending => statusCode == null && error == null;
}

class ApiLogger {
  ApiLogger._();
  static final ApiLogger instance = ApiLogger._();

  final List<ApiLogEntry> _logs = [];
  final List<void Function()> _listeners = [];

  List<ApiLogEntry> get logs => List.unmodifiable(_logs);

  void addListener(void Function() listener) => _listeners.add(listener);
  void removeListener(void Function() listener) => _listeners.remove(listener);
  void _notify() { for (final l in _listeners) l(); }

  /// يُضاف عند بداية الطلب — يرجع ID للتحديث لاحقاً
  String logRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    String? body,
  }) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    _logs.insert(0, ApiLogEntry(
      id: id,
      timestamp: DateTime.now(),
      method: method,
      url: url,
      requestHeaders: headers,
      requestBody: body,
    ));
    _notify();
    return id;
  }

  /// يُحدَّث عند اكتمال الطلب
  void logResponse({
    required String id,
    required int statusCode,
    required String responseBody,
    required Duration duration,
  }) {
    final idx = _logs.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final old = _logs[idx];
    _logs[idx] = ApiLogEntry(
      id: old.id,
      timestamp: old.timestamp,
      method: old.method,
      url: old.url,
      requestHeaders: old.requestHeaders,
      requestBody: old.requestBody,
      statusCode: statusCode,
      responseBody: responseBody,
      duration: duration,
    );
    _notify();
  }

  /// يُحدَّث عند حدوث خطأ
  void logError({
    required String id,
    required String error,
    required Duration duration,
  }) {
    final idx = _logs.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final old = _logs[idx];
    _logs[idx] = ApiLogEntry(
      id: old.id,
      timestamp: old.timestamp,
      method: old.method,
      url: old.url,
      requestHeaders: old.requestHeaders,
      requestBody: old.requestBody,
      error: error,
      duration: duration,
    );
    _notify();
  }

  void clear() {
    _logs.clear();
    _notify();
  }
}
