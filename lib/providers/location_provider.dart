import 'package:flutter/foundation.dart';
import 'package:urbanwatch_mobile/services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  LocationData? _currentLocation;
  bool _isLoading = false;
  String? _error;

  LocationData? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLocation => _currentLocation != null;

  /// Initialize location on app start
  Future<void> initializeLocation() async {
    await getCurrentLocation();
  }

  /// Get current location and address
  Future<void> getCurrentLocation() async {
    _setLoading(true);
    _error = null;
    notifyListeners();

    try {
      final locationData = await LocationService.getCurrentLocationAndAddress();
      
      if (locationData != null) {
        _currentLocation = locationData;
        _error = null;
        
        if (kDebugMode) {
          print('📍 LOCATION: Got location - ${locationData.address}');
        }
      } else {
        _error = 'Unable to get location';
        if (kDebugMode) {
          print('📍 LOCATION: Failed to get location');
        }
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('📍 LOCATION: Error - $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh location
  Future<void> refreshLocation() async {
    await getCurrentLocation();
  }

  /// Clear location data
  void clearLocation() {
    _currentLocation = null;
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
