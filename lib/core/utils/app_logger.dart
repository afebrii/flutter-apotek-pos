import 'dart:developer' as developer;

class AppLogger {
  static bool _enabled = true;

  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  static void info(String message, {String? tag}) {
    if (!_enabled) return;
    developer.log('[INFO] $message', name: tag ?? 'APP');
  }

  static void debug(String message, {String? tag}) {
    if (!_enabled) return;
    developer.log('[DEBUG] $message', name: tag ?? 'APP');
  }

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;
    developer.log(
      '[ERROR] $message',
      name: tag ?? 'APP',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void warning(String message, {String? tag}) {
    if (!_enabled) return;
    developer.log('[WARN] $message', name: tag ?? 'APP');
  }

  static void blocEvent(String blocName, String event, {String? tag}) {
    if (!_enabled) return;
    developer.log(
      '[BLOC EVENT] $blocName: $event',
      name: tag ?? 'BLOC',
    );
  }

  static void blocState(String blocName, String state, {String? tag}) {
    if (!_enabled) return;
    developer.log(
      '[BLOC STATE] $blocName: $state',
      name: tag ?? 'BLOC',
    );
  }

  static void apiRequest(
    String method,
    String url, {
    dynamic body,
    String? tag,
  }) {
    if (!_enabled) return;
    developer.log(
      '[API REQUEST] $method $url\nBody: $body',
      name: tag ?? 'API',
    );
  }

  static void apiResponse(
    String url,
    int statusCode,
    String body, {
    String? tag,
    bool fullBody = false,
  }) {
    if (!_enabled) return;
    final truncatedBody = fullBody
        ? body
        : body.length > 2000
            ? '${body.substring(0, 2000)}...'
            : body;
    developer.log(
      '[API RESPONSE] $url\nStatus: $statusCode\nBody: $truncatedBody',
      name: tag ?? 'API',
    );
  }
}
