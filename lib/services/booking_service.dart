import '../models/fleet.dart';
import '../models/booking.dart';
import '../models/location_model.dart';
import 'api_service.dart';

class BookingService {
  final ApiService _apiService;

  BookingService(this._apiService);

  Future<List<Fleet>> calculateFare({
    required List<LocationModel> locations,
    DateTime? bookingTime,
    String scheduleType = 'asap',
    int? fleetId,
    double? distanceMi,
    double? durationMin,
  }) async {
    try {
      final response = await _apiService.post(
        '/fare/calc',
        data: {
          if (fleetId != null) 'fleet_id': fleetId,
          if (bookingTime != null) 'booking_time': bookingTime.toIso8601String(),
          'schedule_type': scheduleType,
          'locations': locations.map((loc) => loc.toJson()).toList(),
          if (distanceMi != null) 'distance_mi': distanceMi,
          if (durationMin != null) 'duration_min': durationMin,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final fleetList = data['data'] as List<dynamic>? ?? data['fleets'] as List<dynamic>? ?? [];
      
      return fleetList
          .map((fleet) => Fleet.fromJson(fleet as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Booking> createBooking({
    required int fleetId,
    required List<LocationModel> locations,
    DateTime? bookingTime,
    String scheduleType = 'asap',
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post(
        '/bookings',
        data: {
          'fleet_id': fleetId,
          'locations': locations.map((loc) => loc.toJson()).toList(),
          if (bookingTime != null) 'booking_time': bookingTime.toIso8601String(),
          'schedule_type': scheduleType,
          if (paymentMethod != null) 'payment_method': paymentMethod,
          if (notes != null) 'notes': notes,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final bookingData = data['data'] as Map<String, dynamic>? ?? data;
      
      return Booking.fromJson(bookingData);
    } catch (e) {
      rethrow;
    }
  }

  Future<Booking> getBooking(int bookingId) async {
    try {
      final response = await _apiService.get('/bookings/$bookingId');
      
      final data = response.data as Map<String, dynamic>;
      final bookingData = data['data'] as Map<String, dynamic>? ?? data;
      
      return Booking.fromJson(bookingData);
    } catch (e) {
      rethrow;
    }
  }

  Future<Booking?> getCurrentBooking() async {
    try {
      final response = await _apiService.get('/bookings/current');
      
      final data = response.data as Map<String, dynamic>;
      
      if (data['data'] == null) return null;
      
      final bookingData = data['data'] as Map<String, dynamic>;
      return Booking.fromJson(bookingData);
    } catch (e) {
      if (e is ApiException && e.isNotFound) {
        return null;
      }
      rethrow;
    }
  }

  Future<List<Booking>> getBookingHistory({
    int page = 1,
    int perPage = 10,
    String? status,
  }) async {
    try {
      final response = await _apiService.get(
        '/bookings/history',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (status != null) 'status': status,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final bookings = data['data'] as List<dynamic>;
      
      return bookings
          .map((booking) => Booking.fromJson(booking as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelBooking(int bookingId, {String? reason}) async {
    try {
      await _apiService.post(
        '/bookings/$bookingId/cancel',
        data: {
          if (reason != null) 'reason': reason,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rateBooking(int bookingId, {
    required double rating,
    String? feedback,
    List<String>? tags,
  }) async {
    try {
      await _apiService.post(
        '/bookings/$bookingId/rate',
        data: {
          'rating': rating,
          if (feedback != null) 'feedback': feedback,
          if (tags != null) 'tags': tags,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Booking>> getScheduledBookings() async {
    try {
      final response = await _apiService.get('/bookings/scheduled');
      
      final data = response.data as Map<String, dynamic>;
      final bookings = data['data'] as List<dynamic>;
      
      return bookings
          .map((booking) => Booking.fromJson(booking as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Booking> updateBooking(int bookingId, {
    DateTime? bookingTime,
    List<LocationModel>? locations,
    String? notes,
  }) async {
    try {
      final response = await _apiService.put(
        '/bookings/$bookingId',
        data: {
          if (bookingTime != null) 'booking_time': bookingTime.toIso8601String(),
          if (locations != null) 'locations': locations.map((loc) => loc.toJson()).toList(),
          if (notes != null) 'notes': notes,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final bookingData = data['data'] as Map<String, dynamic>? ?? data;
      
      return Booking.fromJson(bookingData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendSOS(int bookingId, {
    required String type,
    String? message,
    double? lat,
    double? lng,
  }) async {
    try {
      await _apiService.post(
        '/bookings/$bookingId/sos',
        data: {
          'type': type,
          if (message != null) 'message': message,
          if (lat != null && lng != null) 
            'location': {
              'lat': lat,
              'lng': lng,
            },
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
