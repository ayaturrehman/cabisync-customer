import '../models/location_model.dart';
import 'api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  final ApiService _apiService;

  LocationService(this._apiService);

  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return 'Unknown location';

      final place = placemarks.first;
      final parts = [
        place.street,
        place.locality,
        place.administrativeArea,
      ].where((p) => p != null && p.isNotEmpty);

      return parts.join(', ');
    } catch (e) {
      return 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';
    }
  }

  Future<List<LocationModel>> searchPlaces(String query) async {
    try {
      final response = await _apiService.get(
        '/places/search',
        queryParameters: {'query': query},
      );

      final data = response.data as Map<String, dynamic>;
      final places = data['data'] as List<dynamic>;

      return places
          .map((place) => LocationModel.fromJson(place as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<SavedLocation>> getSavedLocations() async {
    try {
      final response = await _apiService.get('/locations/saved');

      final data = response.data as Map<String, dynamic>;
      final locations = data['data'] as List<dynamic>;

      return locations
          .map((loc) => SavedLocation.fromJson(loc as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<SavedLocation> addSavedLocation({
    required String label,
    required double lat,
    required double lng,
    required String address,
  }) async {
    try {
      final response = await _apiService.post(
        '/locations/saved',
        data: {
          'label': label,
          'lat': lat,
          'lng': lng,
          'address': address,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final locationData = data['data'] as Map<String, dynamic>? ?? data;

      return SavedLocation.fromJson(locationData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSavedLocation(int locationId) async {
    try {
      await _apiService.delete('/locations/saved/$locationId');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LocationModel>> getRecentLocations() async {
    try {
      final response = await _apiService.get('/locations/recent');

      final data = response.data as Map<String, dynamic>;
      final locations = data['data'] as List<dynamic>;

      return locations
          .map((loc) => LocationModel.fromJson(loc as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000;
  }

  Stream<Position> trackPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}
