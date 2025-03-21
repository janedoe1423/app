import 'dart:developer' as developer;

class Logger {
  // Log levels
  static const int _kVerboseLevel = 0;
  static const int _kDebugLevel = 1;
  static const int _kInfoLevel = 2;
  static const int _kWarningLevel = 3;
  static const int _kErrorLevel = 4;
  
  // Current minimum log level
  static int _currentLevel = _kInfoLevel;
  
  // Set minimum log level
  static void setLogLevel(int level) {
    _currentLevel = level;
  }
  
  // Log with label and level check
  static void _log(String message, String label, int level) {
    if (level >= _currentLevel) {
      final time = DateTime.now().toIso8601String();
      developer.log('$time | $message', name: 'EduGenius:$label');
    }
  }
  
  // Debug log
  static void debug(String message) {
    _log(message, 'DEBUG', _kDebugLevel);
  }
  
  // Info log
  static void info(String message) {
    _log(message, 'INFO', _kInfoLevel);
  }
  
  // Warning log
  static void warning(String message) {
    _log(message, 'WARN', _kWarningLevel);
  }
  
  // Error log
  static void error(String message) {
    _log(message, 'ERROR', _kErrorLevel);
  }
  
  // Verbose log
  static void verbose(String message) {
    _log(message, 'VERBOSE', _kVerboseLevel);
  }
  
  // Log method entry
  static void methodEntry(String className, String methodName) {
    verbose('ENTRY: $className.$methodName');
  }
  
  // Log method exit
  static void methodExit(String className, String methodName) {
    verbose('EXIT: $className.$methodName');
  }
  
  // Log with custom tag
  static void custom(String tag, String message) {
    _log(message, tag.toUpperCase(), _kDebugLevel);
  }
  
  // Log an exception with full stack trace
  static void exception(String message, Object exception, StackTrace stackTrace) {
    _log('$message\nException: $exception\nStackTrace:\n$stackTrace', 'EXCEPTION', _kErrorLevel);
  }
}