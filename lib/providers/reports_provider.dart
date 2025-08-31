import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:urbanwatch_mobile/models/api_models.dart';
import 'package:urbanwatch_mobile/widgets/report_card.dart';
import 'package:urbanwatch_mobile/services/api_service.dart';

class ReportsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Report> _reports = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  Pagination? _pagination;

  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  Pagination? get pagination => _pagination;

  Future<bool> submitReport({
    required File imageFile,
    required double lat,
    required double lon,
    required String address,
  }) async {
    _setSubmitting(true);
    _clearError();

    try {
      final response = await _apiService.reportIssue(
        imageFile: imageFile,
        lat: lat,
        lon: lon,
        address: address,
      );

      if (response.isSuccess) {
        // Refresh reports list after successful submission
        await fetchReports();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to submit report: ${e.toString()}');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<void> fetchReports({
    ReportCategory? category,
    ReportStatus? status,
    int limit = 20,
    int offset = 0,
    bool append = false,
    bool forceRefresh = false,
  }) async {
    if (!append) {
      _setLoading(true);
    }
    _clearError();

    try {
      // Clear existing reports if force refresh
      if (forceRefresh) {
        _reports.clear();
        _pagination = null;
      }

      final response = await _apiService.getReports(
        category: category,
        status: status,
        limit: limit,
        offset: offset,
      );

      if (response.isSuccess && response.data != null) {
        if (append) {
          _reports.addAll(response.data!.reports);
        } else {
          _reports = response.data!.reports;
        }
        _pagination = response.data!.pagination;
        notifyListeners();
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Failed to fetch reports: ${e.toString()}');
    } finally {
      if (!append) {
        _setLoading(false);
      }
    }
  }

  Future<void> loadMoreReports({
    ReportCategory? category,
    ReportStatus? status,
  }) async {
    if (_pagination != null && _reports.length < _pagination!.total) {
      await fetchReports(
        category: category,
        status: status,
        limit: _pagination!.limit,
        offset: _reports.length,
        append: true,
      );
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  void reset() {
    _reports.clear();
    _pagination = null;
    _clearError();
    notifyListeners();
  }
}
