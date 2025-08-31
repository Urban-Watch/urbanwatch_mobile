import 'package:urbanwatch_mobile/config/app_config.dart';

class ApiConstants {
  // Base URL for the UrbanWatch API from environment
  static String get baseUrl => AppConfig.apiBaseUrl;
  
  // API Endpoints
  static String get reportIssue => '$baseUrl/report-issue';
  static String get getReports => '$baseUrl/get-reports';
  static String get userSignup => '$baseUrl/user/signup';
  static String get userLogin => '$baseUrl/user/login';
  
  // HTTP Headers
  static const String contentTypeJson = 'application/json';
  static const String contentTypeMultipart = 'multipart/form-data';
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
  
  // Request timeouts from configuration
  static Duration get requestTimeout => AppConfig.requestTimeout;
  static Duration get uploadTimeout => AppConfig.uploadTimeout;
}
