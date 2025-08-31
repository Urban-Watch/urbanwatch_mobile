import 'package:flutter/foundation.dart';
import 'package:urbanwatch_mobile/models/api_models.dart';
import 'package:urbanwatch_mobile/services/auth_service.dart';
import 'package:urbanwatch_mobile/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    _setLoading(true);
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _user = await _authService.getUser();
      }
    } catch (e) {
      _setError('Failed to initialize user: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String phone,
    required String name,
    required String address,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.signUp(
        phone: phone,
        name: name,
        address: address,
      );

      if (response.isSuccess && response.data != null) {
        await _authService.saveAuthData(
          response.data!.token,
          response.data!.user,
        );
        _user = response.data!.user;
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Signup failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({required String phone}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.login(phone: phone);

      if (response.isSuccess && response.data != null) {
        await _authService.saveAuthData(
          response.data!.token,
          response.data!.user,
        );
        _user = response.data!.user;
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      // Clear all authentication data
      await _authService.logout();
      _user = null;
      _error = null; // Clear any previous errors
      
      if (kDebugMode) {
        print('🔐 AUTH: Logout completed, user set to null');
      }
      
      // Notify listeners immediately
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
      if (kDebugMode) {
        print('🔐 AUTH: Logout failed: ${e.toString()}');
      }
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
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
}
