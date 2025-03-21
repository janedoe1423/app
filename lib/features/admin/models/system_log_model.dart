enum LogSeverity {
  info,
  warning,
  error,
  critical
}

class SystemLog {
  final String id;
  final String message;
  final LogSeverity severity;
  final DateTime timestamp;
  final String? userId;
  final String? action;
  final String source;
  final String details;

  SystemLog({
    required this.id,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.userId,
    this.action,
    this.source = 'System',
    this.details = '',
  });

  String get severityString {
    switch (severity) {
      case LogSeverity.info:
        return 'Info';
      case LogSeverity.warning:
        return 'Warning';
      case LogSeverity.error:
        return 'Error';
      case LogSeverity.critical:
        return 'Critical';
      default:
        return 'Unknown';
    }
  }

  factory SystemLog.fromJson(Map<String, dynamic> json) {
    return SystemLog(
      id: json['id'] ?? '',
      message: json['message'] ?? '',
      severity: _parseSeverity(json['severity']),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      userId: json['userId'],
      action: json['action'],
      source: json['source'] ?? 'System',
      details: json['details'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'severity': severity.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'action': action,
      'source': source,
      'details': details,
    };
  }

  static LogSeverity _parseSeverity(String? severityStr) {
    if (severityStr == null) return LogSeverity.info;
    
    switch (severityStr.toLowerCase()) {
      case 'warning':
        return LogSeverity.warning;
      case 'error':
        return LogSeverity.error;
      case 'critical':
        return LogSeverity.critical;
      case 'info':
      default:
        return LogSeverity.info;
    }
  }
}