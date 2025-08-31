import 'package:urbanwatch_mobile/widgets/report_card.dart';

// Updated Report model to match backend schema
class Report {
  final String reportId;
  final List<String> userIds;
  final int peopleReported;
  final ReportCategory category;
  final String title;
  final String aiAnalysis;
  final List<String> images;
  final Location location;
  final int criticalityScore;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Report({
    required this.reportId,
    required this.userIds,
    required this.peopleReported,
    required this.category,
    required this.title,
    required this.aiAnalysis,
    required this.images,
    required this.location,
    required this.criticalityScore,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      reportId: json['report_id'] ?? '',
      userIds: List<String>.from(json['user_ids'] ?? []),
      peopleReported: json['people_reported'] ?? 0,
      category: ReportCategory.fromString(json['category'] ?? 'potholes'),
      title: json['title'] ?? '',
      aiAnalysis: json['description'] ?? json['ai_analysis'] ?? '', // Map description field from API
      images: List<String>.from(json['images'] ?? []),
      location: Location.fromJson(json['location'] ?? {}),
      criticalityScore: json['criticality_score'] ?? 0,
      status: ReportStatus.fromString(json['status'] ?? 'waiting_for_attention'),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_id': reportId,
      'user_ids': userIds,
      'people_reported': peopleReported,
      'category': category.value,
      'title': title,
      'description': description,
      'images': images,
      'location': location.toJson(),
      'criticality_score': criticalityScore,
      'status': status.apiValue,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters for backwards compatibility with existing UI
  String get imageUrl => images.isNotEmpty ? images.first : '';
  String get description => aiAnalysis;
  int get id => int.tryParse(reportId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  String get date => '${createdAt.day} ${_getMonthName(createdAt.month)} ${createdAt.year}';
  String get time => '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';

  String _getMonthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }
}

class Location {
  final double lat;
  final double lon;
  final String address;

  Location({
    required this.lat,
    required this.lon,
    required this.address,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] ?? 0.0).toDouble(),
      lon: (json['lon'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lon': lon,
      'address': address,
    };
  }
}

// Updated ReportCategory enum to match backend
enum ReportCategory {
  potholes,
  trashOverflow;

  String get value {
    switch (this) {
      case ReportCategory.potholes:
        return 'potholes';
      case ReportCategory.trashOverflow:
        return 'trash_overflow';
    }
  }

  String get displayName {
    switch (this) {
      case ReportCategory.potholes:
        return 'Potholes';
      case ReportCategory.trashOverflow:
        return 'Trash Overflow';
    }
  }

  static ReportCategory fromString(String value) {
    switch (value) {
      case 'potholes':
        return ReportCategory.potholes;
      case 'trash_overflow':
        return ReportCategory.trashOverflow;
      default:
        return ReportCategory.potholes;
    }
  }
}

// User model to match backend schema
class User {
  final String userId;
  final String mobileNo;
  final String name;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.userId,
    required this.mobileNo,
    required this.name,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? '',
      // Backend returns 'phone' in response but expects 'mobile_no' in requests
      mobileNo: json['phone'] ?? json['mobile_no'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'mobile_no': mobileNo, // Always use mobile_no for consistency
      'name': name,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// API Response models
class ApiResponse<T> {
  final String status;
  final String message;
  final T? data;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: fromJsonT != null && json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  bool get isSuccess => status == 'success';
}

class LoginResponse {
  final String token;
  final User user;

  LoginResponse({
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      user: User.fromJson(json['data'] ?? {}),
    );
  }
}

class ReportResponse {
  final String reportId;

  ReportResponse({required this.reportId});

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    return ReportResponse(
      reportId: json['report_id'] ?? '',
    );
  }
}

class ReportsListResponse {
  final List<Report> reports;
  final Pagination pagination;

  ReportsListResponse({
    required this.reports,
    required this.pagination,
  });

  factory ReportsListResponse.fromJson(Map<String, dynamic> json) {
    return ReportsListResponse(
      reports: (json['reports'] as List? ?? [])
          .map((report) => Report.fromJson(report))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class Pagination {
  final int total;
  final int limit;
  final int offset;

  Pagination({
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 20,
      offset: json['offset'] ?? 0,
    );
  }
}
