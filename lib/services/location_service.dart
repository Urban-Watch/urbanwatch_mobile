import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  static const String _locationIqApiKey = 'pk.5d1b9cdb2713e4d962feb9991a457af6';
  static const String _baseUrl = 'https://us1.locationiq.com/v1/reverse';

  /// Get current position and address
  static Future<LocationData?> getCurrentLocationAndAddress() async {
    try {
      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      String address = await _getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );
    } catch (e) {
      print('Location service error: $e');
      return null;
    }
  }

  /// Convert lat/lng to human readable address using LocationIQ API
  static Future<String> _getAddressFromCoordinates(double lat, double lon) async {
    try {
      final url = '$_baseUrl?key=$_locationIqApiKey&lat=$lat&lon=$lon&format=json';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("data from the api is : ${data}");
        
        // Use display_name directly as suggested
        final displayName = data['display_name'] as String?;
        
        if (displayName != null && displayName.isNotEmpty) {
          return displayName;
        }
      }
      
      // Fallback to coordinates if API fails
      return 'Lat: ${lat.toStringAsFixed(4)}, Lon: ${lon.toStringAsFixed(4)}';
    } catch (e) {
      print('Address resolution error: $e');
      // Fallback to coordinates if address resolution fails
      return 'Lat: ${lat.toStringAsFixed(4)}, Lon: ${lon.toStringAsFixed(4)}';
    }
  }

  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }
}

/// Data class to hold location information
class LocationData {
  final double latitude;
  final double longitude;
  final String address;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lon: $longitude, address: $address)';
  }
}
