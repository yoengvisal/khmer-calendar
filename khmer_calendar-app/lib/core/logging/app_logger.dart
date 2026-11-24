import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error }

/// Thin logging facade. Output goes to `dart:developer` (visible in DevTools /
/// IDE console) and is filtered by [minLevel].
class AppLogger {
  const AppLogger({
    this.minLevel = LogLevel.info,
    this.name = 'khmer_calendar',
  });

  final LogLevel minLevel;
  final String name;

  void debug(String message) => _log(LogLevel.debug, message);
  void info(String message) => _log(LogLevel.info, message);
  void warning(String message, [Object? error]) =>
      _log(LogLevel.warning, message, error);
  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.error, message, error, stackTrace);

  void _log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (level.index < minLevel.index) return;
    developer.log(
      message,
      name: name,
      level: switch (level) {
        LogLevel.debug => 500,
        LogLevel.info => 800,
        LogLevel.warning => 900,
        LogLevel.error => 1000,
      },
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// Field names (case-insensitive substrings) whose values are never logged.
const List<String> _sensitiveKeys = [
  'authorization',
  'cookie',
  'token',
  'password',
  'secret',
  'api-key',
  'apikey',
];

const String redacted = '***';

bool isSensitiveKey(String key) {
  final lower = key.toLowerCase();
  return _sensitiveKeys.any(lower.contains);
}

/// Recursively redacts sensitive values in maps/lists (headers, JSON bodies).
Object? redact(Object? value) {
  if (value is Map) {
    return {
      for (final entry in value.entries)
        entry.key: isSensitiveKey('${entry.key}')
            ? redacted
            : redact(entry.value),
    };
  }
  if (value is List) return [for (final item in value) redact(item)];
  return value;
}
