import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbanwatch_mobile/models/api_models.dart';
import 'package:urbanwatch_mobile/config/app_config.dart';
import 'dart:convert';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Save user authentication data
  Future<void> saveAuthData(String token, User user) async {
    await _initPrefs();
    await _prefs!.setString(_tokenKey, token);
    await _prefs!.setString(_userKey, json.encode(user.toJson()));
    await _prefs!.setBool(_isLoggedInKey, true);
    
    if (AppConfig.enableAuthLogging) {
      print('🔐 AUTH: Saved authentication data for user: ${user.name} (${user.mobileNo})');
    }
  }

  // Get stored token
  Future<String?> getToken() async {
    await _initPrefs();
    final token = _prefs!.getString(_tokenKey);
    
    if (AppConfig.enableAuthLogging && token != null) {
      final maskedToken = '${token.substring(0, 10)}...${token.substring(token.length - 4)}';
      print('🔐 AUTH: Retrieved token: $maskedToken');
    }
    
    return token;
  }

  // Get stored user data
  Future<User?> getUser() async {
    await _initPrefs();
    final userJson = _prefs!.getString(_userKey);
    if (userJson != null) {
      try {
        final userData = json.decode(userJson);
        return User.fromJson(userData);
      } catch (e) {
        // If there's an error parsing user data, clear it
        await clearAuthData();
        return null;
      }
    }
    return null;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    await _initPrefs();
    return _prefs!.getBool(_isLoggedInKey) ?? false;
  }

  // Clear all authentication data
  Future<void> clearAuthData() async {
    await _initPrefs();
    await _prefs!.remove(_tokenKey);
    await _prefs!.remove(_userKey);
    await _prefs!.remove(_isLoggedInKey); // Changed from setBool(false) to remove()
    
    if (AppConfig.enableAuthLogging) {
      print('🔐 AUTH: Cleared all authentication data');
    }
  }

  // Logout user
  Future<void> logout() async {
    await clearAuthData();
    if (AppConfig.enableAuthLogging) {
      print('🔐 AUTH: User logged out successfully');
    }
  }

  // Check if token is still valid (you might want to implement token expiry logic)
  Future<bool> isTokenValid() async {
    final token = await getToken();
    // For now, just check if token exists
    // In a real app, you might want to validate the token with the server
    return token != null && token.isNotEmpty;
  }
}
