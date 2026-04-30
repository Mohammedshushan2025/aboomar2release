// مسار الملف: lib/services/api_exceptions.dart

// الفئة الأساسية لجميع أخطاء الـ API
class ApiException implements Exception {
  final String _messageKey; // مفتاح الترجمة للرسالة

  ApiException(this._messageKey);

  // الدالة التي ستستخدمها الواجهة للحصول على الرسالة المترجمة
  String getMessage(context) {
    // هنا يجب أن يكون لديك نظام ترجمة، سأفترض أنه موجود
    // final localizations = AppLocalizations.of(context)!;
    // return localizations.translate(_messageKey);

    // حل مؤقت إذا لم يكن نظام الترجمة متاحًا هنا مباشرة
    switch (_messageKey) {
      case 'noInternet':
        return 'لا يوجد اتصال بالإنترنت، يرجى التحقق من اتصالك.';
      case 'serverError':
        return 'حدث خطأ في الخادم، يرجى المحاولة مرة أخرى لاحقًا.';
      case 'timeoutError':
        return 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى.';
      case 'userNotFound':
        return 'كود المستخدم غير موجود.';
      case 'invalidPassword':
        return 'كلمة المرور غير صحيحة.';
      default:
        return 'حدث خطأ غير متوقع.';
    }
  }

  @override
  String toString() => _messageKey;
}

// أخطاء الشبكة والخادم
class NoInternetException extends ApiException {
  NoInternetException() : super('noInternet');
}

class ServerException extends ApiException {
  ServerException() : super('serverError');
}

class TimeoutException extends ApiException {
  TimeoutException() : super('timeoutError');
}

// أخطاء خاصة بتسجيل الدخول (منطق العمل)
class UserNotFoundException extends ApiException {
  UserNotFoundException() : super('userNotFound');
}

class InvalidPasswordException extends ApiException {
  InvalidPasswordException() : super('invalidPassword');
}