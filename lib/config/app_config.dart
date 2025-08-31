import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum LogLevel { none, error, warning, info, debug, verbose }

class AppConfig {
  static LogLevel get logLevel {
    if (!kDebugMode) return LogLevel.error;
    
    final levelStr = dotenv.env['LOG_LEVEL']?.toLowerCase() ?? 'debug';
    switch (levelStr) {
      case 'none':
        return LogLevel.none;
      case 'error':
        return LogLevel.error;
      case 'warning':
        return LogLevel.warning;
      case 'info':
        return LogLevel.info;
      case 'verbose':
        return LogLevel.verbose;
      default:
        return LogLevel.debug;
    }
  }

  static bool get enableApiLogging {
    return dotenv.env['ENABLE_API_LOGGING']?.toLowerCase() == 'true' || kDebugMode;
  }

  static bool get enableAuthLogging {
    return dotenv.env['ENABLE_AUTH_LOGGING']?.toLowerCase() == 'true' || kDebugMode;
  }

  static bool get enableNetworkLogging {
    return dotenv.env['ENABLE_NETWORK_LOGGING']?.toLowerCase() == 'true' || kDebugMode;
  }

  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'https://api.urbanwatch.com';
  }

  static Duration get requestTimeout {
    final timeoutStr = dotenv.env['REQUEST_TIMEOUT_SECONDS'];
    final seconds = int.tryParse(timeoutStr ?? '30') ?? 30;
    return Duration(seconds: seconds);
  }

  static Duration get uploadTimeout {
    final timeoutStr = dotenv.env['UPLOAD_TIMEOUT_SECONDS'];
    final seconds = int.tryParse(timeoutStr ?? '120') ?? 120;
    return Duration(seconds: seconds);
  }

  static bool get isProduction {
    return dotenv.env['ENVIRONMENT']?.toLowerCase() == 'production';
  }

  static bool get isDevelopment {
    return !isProduction;
  }

  static void logConfig() {
    if (!kDebugMode) return;
    
    print('🔧 APP CONFIG:');
    print('  Environment: ${isProduction ? 'Production' : 'Development'}');
    print('  API Base URL: $apiBaseUrl');
    print('  Log Level: ${logLevel.name}');
    print('  API Logging: $enableApiLogging');
    print('  Auth Logging: $enableAuthLogging');
    print('  Network Logging: $enableNetworkLogging');
    print('  Request Timeout: ${requestTimeout.inSeconds}s');
    print('  Upload Timeout: ${uploadTimeout.inSeconds}s');
    print('═══════════════════════════════════════');
  }
}
