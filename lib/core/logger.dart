import 'package:logger/logger.dart';

class AppLogger {
  static Logger? _instance;

  static void init() {
    _instance = Logger();
  }

  static void d(String message, [Object? error, StackTrace? stackTrace]) {
    if (error != null) {
      _instance?.d('$message: $error', error: error, stackTrace: stackTrace);
    } else {
      _instance?.d(message);
    }
  }

  static void i(String message, [Object? error, StackTrace? stackTrace]) {
    if (error != null) {
      _instance?.i('$message: $error', error: error, stackTrace: stackTrace);
    } else {
      _instance?.i(message);
    }
  }

  static void w(String message, [Object? error, StackTrace? stackTrace]) {
    if (error != null) {
      _instance?.w('$message: $error', error: error, stackTrace: stackTrace);
    } else {
      _instance?.w(message);
    }
  }

  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    if (error != null) {
      _instance?.e('$message: $error', error: error, stackTrace: stackTrace);
    } else {
      _instance?.e(message);
    }
  }
}

// Alias for convenience
typedef AppLoggerWrapper = AppLogger;
