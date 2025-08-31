import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:urbanwatch_mobile/config/app_config.dart';

class ApiLogger {
  static const String _apiTag = '🌐 API';
  static const String _requestTag = '📤 REQUEST';
  static const String _responseTag = '📥 RESPONSE';
  static const String _errorTag = '❌ ERROR';
  
  // ANSI color codes for terminal output
  static const String _reset = '\x1B[0m';
  static const String _blue = '\x1B[34m';
  static const String _green = '\x1B[32m';
  static const String _red = '\x1B[31m';
  static const String _yellow = '\x1B[33m';
  static const String _cyan = '\x1B[36m';
  static const String _bold = '\x1B[1m';

  /// Log API request details
  static void logRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
    Map<String, dynamic>? queryParams,
  }) {
    if (!AppConfig.enableApiLogging) return;

    final buffer = StringBuffer();
    buffer.writeln('$_cyan$_bold$_apiTag $_requestTag$_reset');
    buffer.writeln('$_blue$method$_reset $url');
    
    if (queryParams != null && queryParams.isNotEmpty) {
      buffer.writeln('${_yellow}Query Params:$_reset');
      queryParams.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    }
    
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('${_yellow}Headers:$_reset');
      headers.forEach((key, value) {
        // Hide sensitive information
        final displayValue = _shouldHideHeader(key) ? '***HIDDEN***' : value;
        buffer.writeln('  $key: $displayValue');
      });
    }
    
    if (body != null) {
      buffer.writeln('${_yellow}Body:$_reset');
      buffer.writeln('  ${_formatBody(body)}');
    }
    
    buffer.writeln('${_cyan}═══════════════════════════════════════$_reset');
    
    developer.log(buffer.toString(), name: 'API_REQUEST');
    if (kDebugMode) {
      print(buffer.toString());
    }
  }

  /// Log API response details
  static void logResponse({
    required String method,
    required String url,
    required int statusCode,
    Map<String, String>? headers,
    dynamic body,
    Duration? duration,
  }) {
    if (!AppConfig.enableApiLogging) return;

    final isSuccess = statusCode >= 200 && statusCode < 300;
    final statusColor = isSuccess ? _green : _red;
    
    final buffer = StringBuffer();
    buffer.writeln('$_cyan$_bold$_apiTag $_responseTag$_reset');
    buffer.writeln('$_blue$method$_reset $url');
    buffer.writeln('${statusColor}Status: $statusCode${_getStatusText(statusCode)}$_reset');
    
    if (duration != null) {
      buffer.writeln('${_yellow}Duration: ${duration.inMilliseconds}ms$_reset');
    }
    
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('${_yellow}Response Headers:$_reset');
      headers.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    }
    
    if (body != null) {
      buffer.writeln('${_yellow}Response Body:$_reset');
      final formattedBody = _formatResponseBody(body, statusCode);
      buffer.writeln('  $formattedBody');
    }
    
    buffer.writeln('${_cyan}═══════════════════════════════════════$_reset');
    
    developer.log(buffer.toString(), name: 'API_RESPONSE');
    if (kDebugMode) {
      print(buffer.toString());
    }
  }

  /// Log API errors
  static void logError({
    required String method,
    required String url,
    required dynamic error,
    StackTrace? stackTrace,
    Duration? duration,
  }) {
    if (!AppConfig.enableApiLogging) return;

    final buffer = StringBuffer();
    buffer.writeln('$_red$_bold$_apiTag $_errorTag$_reset');
    buffer.writeln('$_blue$method$_reset $url');
    
    if (duration != null) {
      buffer.writeln('${_yellow}Duration: ${duration.inMilliseconds}ms$_reset');
    }
    
    buffer.writeln('${_red}Error: $error$_reset');
    
    if (stackTrace != null) {
      buffer.writeln('${_red}Stack Trace:$_reset');
      buffer.writeln('${_red}${stackTrace.toString()}$_reset');
    }
    
    buffer.writeln('${_cyan}═══════════════════════════════════════$_reset');
    
    developer.log(buffer.toString(), name: 'API_ERROR', error: error, stackTrace: stackTrace);
    if (kDebugMode) {
      print(buffer.toString());
    }
  }

  /// Log multipart file upload details
  static void logFileUpload({
    required String method,
    required String url,
    required String fileName,
    required int fileSize,
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) {
    if (!AppConfig.enableApiLogging) return;

    final buffer = StringBuffer();
    buffer.writeln('$_cyan$_bold$_apiTag $_requestTag (File Upload)$_reset');
    buffer.writeln('$_blue$method$_reset $url');
    buffer.writeln('${_yellow}File: $fileName (${_formatFileSize(fileSize)})$_reset');
    
    if (fields != null && fields.isNotEmpty) {
      buffer.writeln('${_yellow}Form Fields:$_reset');
      fields.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    }
    
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('${_yellow}Headers:$_reset');
      headers.forEach((key, value) {
        final displayValue = _shouldHideHeader(key) ? '***HIDDEN***' : value;
        buffer.writeln('  $key: $displayValue');
      });
    }
    
    buffer.writeln('${_cyan}═══════════════════════════════════════$_reset');
    
    developer.log(buffer.toString(), name: 'API_UPLOAD');
    if (kDebugMode) {
      print(buffer.toString());
    }
  }

  /// Helper method to check if header value should be hidden
  static bool _shouldHideHeader(String key) {
    final lowerKey = key.toLowerCase();
    return lowerKey.contains('authorization') ||
           lowerKey.contains('token') ||
           lowerKey.contains('key') ||
           lowerKey.contains('secret');
  }

  /// Format request body for logging
  static String _formatBody(dynamic body) {
    if (body is String) {
      try {
        // Try to parse as JSON for pretty printing
        final decoded = Uri.decodeComponent(body);
        return decoded.length > 1000 ? '${decoded.substring(0, 1000)}...(truncated)' : decoded;
      } catch (e) {
        return body.length > 1000 ? '${body.substring(0, 1000)}...(truncated)' : body;
      }
    }
    return body.toString();
  }

  /// Format response body for logging
  static String _formatResponseBody(dynamic body, int statusCode) {
    final bodyStr = body.toString();
    if (bodyStr.length > 2000) {
      return '${bodyStr.substring(0, 2000)}...(truncated)';
    }
    return bodyStr;
  }

  /// Get human-readable status text
  static String _getStatusText(int statusCode) {
    switch (statusCode) {
      case 200:
        return ' (OK)';
      case 201:
        return ' (Created)';
      case 400:
        return ' (Bad Request)';
      case 401:
        return ' (Unauthorized)';
      case 403:
        return ' (Forbidden)';
      case 404:
        return ' (Not Found)';
      case 500:
        return ' (Internal Server Error)';
      case 502:
        return ' (Bad Gateway)';
      case 503:
        return ' (Service Unavailable)';
      default:
        return '';
    }
  }

  /// Format file size for display
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
