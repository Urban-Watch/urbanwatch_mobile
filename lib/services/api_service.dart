import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:urbanwatch_mobile/constants/api_constants.dart';
import 'package:urbanwatch_mobile/models/api_models.dart';
import 'package:urbanwatch_mobile/widgets/report_card.dart';
import 'package:urbanwatch_mobile/services/auth_service.dart';
import 'package:urbanwatch_mobile/utils/api_logger.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message';
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();
  final AuthService _authService = AuthService();

  // Helper method to get common headers
  Future<Map<String, String>> _getHeaders({bool includeAuth = true, bool isMultipart = false}) async {
    final headers = <String, String>{};
    
    if (!isMultipart) {
      headers[HttpHeaders.contentTypeHeader] = ApiConstants.contentTypeJson;
    }
    
    if (includeAuth) {
      final token = await _authService.getToken();
      if (token != null) {
        headers[ApiConstants.authorizationHeader] = '${ApiConstants.bearerPrefix}$token';
      }
    }
    
    return headers;
  }

  // Helper method to handle API responses
  T _handleResponse<T>(
    http.Response response, 
    T Function(Map<String, dynamic>) fromJson,
    String method,
    String url,
    Duration duration,
  ) {
    // Log the response
    ApiLogger.logResponse(
      method: method,
      url: url,
      statusCode: response.statusCode,
      headers: response.headers,
      body: response.body,
      duration: duration,
    );

    final Map<String, dynamic> data;
    
    try {
      data = json.decode(response.body);
    } catch (e) {
      throw ApiException('Invalid JSON response', statusCode: response.statusCode);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return fromJson(data);
    } else {
      final message = data['message'] ?? 'Request failed';
      throw ApiException(message, statusCode: response.statusCode);
    }
  }

  // User Authentication APIs
  Future<ApiResponse<LoginResponse>> signUp({
    required String phone,
    required String name,
    required String address,
  }) async {
    const method = 'POST';
    final url = ApiConstants.userSignup;
    final stopwatch = Stopwatch()..start();

    try {
      final headers = await _getHeaders(includeAuth: false);
      
      final body = json.encode({
        'mobile_no': phone, // Backend expects 'mobile_no' not 'phone'
        'name': name,
        'address': address,
      });

      // Log the request
      ApiLogger.logRequest(
        method: method,
        url: url,
        headers: headers,
        body: body,
      );

      final response = await _client
          .post(
            Uri.parse(url),
            headers: headers,
            body: body,
          )
          .timeout(ApiConstants.requestTimeout);

      stopwatch.stop();

      return _handleResponse(
        response,
        (data) => ApiResponse.fromJson(
          data,
          (json) => LoginResponse.fromJson(data),
        ),
        method,
        url,
        stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      
      // Log the error
      ApiLogger.logError(
        method: method,
        url: url,
        error: e,
        duration: stopwatch.elapsed,
      );
      
      if (e is ApiException) rethrow;
      throw ApiException('Network error during signup: ${e.toString()}');
    }
  }

  Future<ApiResponse<LoginResponse>> login({required String phone}) async {
    const method = 'POST';
    final url = ApiConstants.userLogin;
    final stopwatch = Stopwatch()..start();

    try {
      final headers = await _getHeaders(includeAuth: false);
      
      final body = json.encode({'mobile_no': phone}); // Backend expects 'mobile_no' not 'phone'

      // Log the request
      ApiLogger.logRequest(
        method: method,
        url: url,
        headers: headers,
        body: body,
      );

      final response = await _client
          .post(
            Uri.parse(url),
            headers: headers,
            body: body,
          )
          .timeout(ApiConstants.requestTimeout);

      stopwatch.stop();

      return _handleResponse(
        response,
        (data) => ApiResponse.fromJson(
          data,
          (json) => LoginResponse.fromJson(data),
        ),
        method,
        url,
        stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      
      // Log the error
      ApiLogger.logError(
        method: method,
        url: url,
        error: e,
        duration: stopwatch.elapsed,
      );
      
      if (e is ApiException) rethrow;
      throw ApiException('Network error during login: ${e.toString()}');
    }
  }

  // Report APIs
  Future<ApiResponse<ReportResponse>> reportIssue({
    required File imageFile,
    required double lat,
    required double lon,
    required String address,
  }) async {
    const method = 'POST';
    final url = ApiConstants.reportIssue;
    final stopwatch = Stopwatch()..start();

    try {
      final headers = await _getHeaders(isMultipart: true);
      
      final request = http.MultipartRequest(
        method,
        Uri.parse(url),
      );

      request.headers.addAll(headers);

      // Add image file with proper MIME type detection
      final imageStream = http.ByteStream(imageFile.openRead());
      final imageLength = await imageFile.length();
      
      // Get file extension and determine MIME type
      final String fileName = imageFile.path.split('/').last;
      final String fileExtension = fileName.split('.').last.toLowerCase();
      
      String mimeType;
      String finalFileName;
      
      switch (fileExtension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          finalFileName = fileName.endsWith('.jpg') || fileName.endsWith('.jpeg') 
              ? fileName 
              : 'report_image.jpg';
          break;
        case 'png':
          mimeType = 'image/png';
          finalFileName = fileName.endsWith('.png') ? fileName : 'report_image.png';
          break;
        case 'webp':
          mimeType = 'image/webp';
          finalFileName = fileName.endsWith('.webp') ? fileName : 'report_image.webp';
          break;
        default:
          // Default to JPEG if unknown
          mimeType = 'image/jpeg';
          finalFileName = 'report_image.jpg';
      }
      
      final imageMultipart = http.MultipartFile(
        'image',
        imageStream,
        imageLength,
        filename: finalFileName,
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(imageMultipart);

      // Add location data as separate fields (backend expects latitude and longitude, not nested location)
      request.fields['latitude'] = lat.toString();
      request.fields['longitude'] = lon.toString();
      request.fields['address'] = address; // Use the actual address from LocationIQ

      // Log the file upload request
      ApiLogger.logFileUpload(
        method: method,
        url: url,
        fileName: finalFileName,
        fileSize: imageLength,
        fields: {
          'latitude': lat.toString(),
          'longitude': lon.toString(),
          'address': address,
        },
        headers: headers,
      );

      final streamedResponse = await _client
          .send(request)
          .timeout(ApiConstants.uploadTimeout);

      final response = await http.Response.fromStream(streamedResponse);
      stopwatch.stop();

      return _handleResponse(
        response,
        (data) => ApiResponse.fromJson(
          data,
          (json) => ReportResponse.fromJson(json),
        ),
        method,
        url,
        stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      
      // Log the error
      ApiLogger.logError(
        method: method,
        url: url,
        error: e,
        duration: stopwatch.elapsed,
      );
      
      if (e is ApiException) rethrow;
      throw ApiException('Network error during report submission: ${e.toString()}');
    }
  }

  Future<ApiResponse<ReportsListResponse>> getReports({
    ReportCategory? category,
    ReportStatus? status,
    int limit = 20,
    int offset = 0,
  }) async {
    const method = 'GET';
    final stopwatch = Stopwatch()..start();

    try {
      final headers = await _getHeaders();
      
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (category != null) {
        queryParams['category'] = category.value;
      }

      if (status != null) {
        queryParams['status'] = status.apiValue;
      }

      final uri = Uri.parse(ApiConstants.getReports).replace(
        queryParameters: queryParams,
      );

      // Log the request
      ApiLogger.logRequest(
        method: method,
        url: uri.toString(),
        headers: headers,
        queryParams: queryParams,
      );

      final response = await _client
          .get(uri, headers: headers)
          .timeout(ApiConstants.requestTimeout);

      stopwatch.stop();

      return _handleResponse(
        response,
        (data) => ApiResponse.fromJson(
          data,
          (json) => ReportsListResponse.fromJson(json),
        ),
        method,
        uri.toString(),
        stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      
      // Log the error
      ApiLogger.logError(
        method: method,
        url: ApiConstants.getReports,
        error: e,
        duration: stopwatch.elapsed,
      );
      
      if (e is ApiException) rethrow;
      throw ApiException('Network error while fetching reports: ${e.toString()}');
    }
  }

  // Clean up resources
  void dispose() {
    _client.close();
  }
}
