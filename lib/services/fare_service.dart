import '../api/api_service.dart';
import '../models/fare_estimate.dart';

class FareService {
  /// Calculate fare estimates for all available fleet types
  ///
  /// Returns a list of fare estimates, one for each fleet type
  /// [authToken] - User's authentication token
  /// [pickupLat] - Pickup latitude
  /// [pickupLng] - Pickup longitude
  /// [pickupAddress] - Pickup address
  /// [dropoffLat] - Dropoff latitude
  /// [dropoffLng] - Dropoff longitude
  /// [dropoffAddress] - Dropoff address
  /// [bookingTime] - Booking time (ISO 8601 format or 'now')
  /// [scheduleType] - 'asap' or 'schedule'
  /// [stops] - Optional list of stop locations (each with lat, lng, address)
  static Future<List<FareEstimate>> calculateFares({
    required String authToken,
    required double pickupLat,
    required double pickupLng,
    required String pickupAddress,
    required double dropoffLat,
    required double dropoffLng,
    required String dropoffAddress,
    String? bookingTime,
    String scheduleType = 'asap',
    List<Map<String, dynamic>>? stops,
  }) async {
    // Build locations array
    final locations = <Map<String, dynamic>>[];

    // Add pickup location
    locations.add({
      'lat': pickupLat,
      'lng': pickupLng,
      'address': pickupAddress,
      'type': 'pickup',
    });

    // Add stops if any
    if (stops != null && stops.isNotEmpty) {
      for (final stop in stops) {
        locations.add({
          'lat': stop['lat'],
          'lng': stop['lng'],
          'address': stop['address'],
          'type': 'stop',
        });
      }
    }

    // Add dropoff location
    locations.add({
      'lat': dropoffLat,
      'lng': dropoffLng,
      'address': dropoffAddress,
      'type': 'dropoff',
    });

    // Use current time if not provided
    final time = bookingTime ?? DateTime.now().toIso8601String();

    try {
      final response = await ApiService.calculateFare(
        authToken: authToken,
        bookingTime: time,
        scheduleType: scheduleType,
        locations: locations,
      );

      // Backend returns array of fare estimates
      return response
          .map((item) => FareEstimate.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Fare calculation error: $e');
      rethrow;
    }
  }

  /// Calculate fare estimates with distance and duration pre-calculated
  static Future<List<FareEstimate>> calculateFaresWithMetrics({
    required String authToken,
    required double pickupLat,
    required double pickupLng,
    required String pickupAddress,
    required double dropoffLat,
    required double dropoffLng,
    required String dropoffAddress,
    required double distanceMi,
    required double durationMin,
    String? bookingTime,
    String scheduleType = 'asap',
    List<Map<String, dynamic>>? stops,
  }) async {
    // Build locations array
    final locations = <Map<String, dynamic>>[];

    // Add pickup location
    locations.add({
      'lat': pickupLat,
      'lng': pickupLng,
      'address': pickupAddress,
      'type': 'pickup',
    });

    // Add stops if any
    if (stops != null && stops.isNotEmpty) {
      for (final stop in stops) {
        locations.add({
          'lat': stop['lat'],
          'lng': stop['lng'],
          'address': stop['address'],
          'type': 'stop',
        });
      }
    }

    // Add dropoff location
    locations.add({
      'lat': dropoffLat,
      'lng': dropoffLng,
      'address': dropoffAddress,
      'type': 'dropoff',
    });

    // Use current time if not provided
    final time = bookingTime ?? DateTime.now().toIso8601String();

    try {
      final response = await ApiService.calculateFare(
        authToken: authToken,
        bookingTime: time,
        scheduleType: scheduleType,
        locations: locations,
        distanceMi: distanceMi,
        durationMin: durationMin,
      );

      // Backend returns array of fare estimates
      return response
          .map((item) => FareEstimate.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Fare calculation error: $e');
      rethrow;
    }
  }
}
