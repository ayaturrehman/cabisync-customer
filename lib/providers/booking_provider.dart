// lib/providers/booking_provider.dart
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/location_model.dart';
import '../services/api_service.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService = BookingService(ApiService());

  Booking? _current;
  List<Booking> _history = [];
  bool _loading = false;
  String? _errorMessage;

  Booking? get current => _current;
  List<Booking> get history => _history;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  Future<void> loadHistory() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _history = await _bookingService.getBookingHistory();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Booking> createBooking({
    required String fleetId,
    required List<Map<String, dynamic>> locationData,
    DateTime? bookingTime,
    String scheduleType = 'asap',
    String? paymentMethodId,
  }) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final locations = locationData
          .map((loc) => LocationModel(
                lat: (loc['lat'] as num).toDouble(),
                lng: (loc['lng'] as num).toDouble(),
                address: loc['address'] as String,
                type: loc['type'] as String,
              ))
          .toList();

      final booking = await _bookingService.createBooking(
        fleetId: fleetId,
        locations: locations,
        bookingTime: bookingTime,
        scheduleType: scheduleType,
        paymentMethodId: paymentMethodId,
      );

      _current = booking;
      _loading = false;
      notifyListeners();
      return booking;
    } catch (e) {
      _errorMessage = e.toString();
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  void setCurrent(Booking booking) {
    _current = booking;
    notifyListeners();
  }

  void clearCurrent() {
    _current = null;
    notifyListeners();
  }
}
