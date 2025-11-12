// lib/providers/booking_provider.dart
import 'package:flutter/material.dart';
import 'dart:math';
import '../models/booking.dart';

class BookingProvider extends ChangeNotifier {
  Booking? _current;

  Booking? get current => _current;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> createBooking({
    required SimpleLatLng pickupLocation,
    required String pickupAddress,
    required SimpleLatLng dropLocation,
    required String dropAddress,
    required String vehicleType,
  }) async {
    _loading = true;
    notifyListeners();

    // Simulate network call / fare calculation
    await Future.delayed(const Duration(seconds: 1));

    final fare = _estimateFare(pickupLocation, dropLocation, vehicleType);

    _current = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      pickupLocation: pickupLocation,
      pickupAddress: pickupAddress,
      dropLocation: dropLocation,
      dropAddress: dropAddress,
      vehicleType: vehicleType,
      fare: fare,
    );

    _loading = false;
    notifyListeners();
  }

  double _estimateFare(SimpleLatLng a, SimpleLatLng b, String vehicleType) {
    final dx = a.latitude - b.latitude;
    final dy = a.longitude - b.longitude;
    final km = sqrt(dx * dx + dy * dy) * 111.0; // rough deg->km
    double base = 50.0;
    double perKm = vehicleType.toLowerCase().contains('sedan') ? 12.0 : 18.0;
    return (base + perKm * km).clamp(60.0, 9999.0);
  }
}
