/// Example: How to use the Fare Calculation Service
///
/// This file demonstrates how to calculate fare estimates for rides.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/fare_service.dart';
import '../models/fare_estimate.dart';
import '../providers/auth_provider.dart';

/// Example 1: Calculate fare with just pickup and dropoff
Future<void> exampleSimpleFareCalculation(BuildContext context) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final token = authProvider.token;

  if (token == null) {
    print('User not authenticated');
    return;
  }

  try {
    final fareEstimate = await FareService.calculateFare(
      authToken: token,
      pickupLat: 51.5074,
      pickupLng: -0.1278,
      pickupAddress: '10 Downing Street, London',
      dropoffLat: 51.5194,
      dropoffLng: -0.1270,
      dropoffAddress: 'King\'s Cross Station, London',
      scheduleType: 'asap', // or 'schedule'
    );

    print('Fare: ${fareEstimate.formattedTotalFare}');
    print('Distance: ${fareEstimate.formattedDistance}');
    print('Duration: ${fareEstimate.formattedDuration}');
  } catch (e) {
    print('Error calculating fare: $e');
  }
}

/// Example 2: Calculate fare with stops
Future<void> exampleFareWithStops(BuildContext context) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final token = authProvider.token;

  if (token == null) return;

  try {
    final fareEstimate = await FareService.calculateFare(
      authToken: token,
      pickupLat: 51.5074,
      pickupLng: -0.1278,
      pickupAddress: '10 Downing Street, London',
      dropoffLat: 51.5194,
      dropoffLng: -0.1270,
      dropoffAddress: 'King\'s Cross Station, London',
      stops: [
        {'lat': 51.5138, 'lng': -0.1424, 'address': 'Oxford Circus, London'},
        {'lat': 51.5155, 'lng': -0.1415, 'address': 'Regent Street, London'},
      ],
      scheduleType: 'asap',
    );

    print('Total fare with stops: ${fareEstimate.formattedTotalFare}');
  } catch (e) {
    print('Error: $e');
  }
}

/// Example 3: Schedule a ride for later
Future<void> exampleScheduledRide(BuildContext context) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final token = authProvider.token;

  if (token == null) return;

  // Schedule for 2 hours from now
  final scheduledTime = DateTime.now().add(const Duration(hours: 2));

  try {
    final fareEstimate = await FareService.calculateFare(
      authToken: token,
      pickupLat: 51.5074,
      pickupLng: -0.1278,
      pickupAddress: '10 Downing Street, London',
      dropoffLat: 51.5194,
      dropoffLng: -0.1270,
      dropoffAddress: 'King\'s Cross Station, London',
      bookingTime: scheduledTime.toIso8601String(),
      scheduleType: 'schedule',
    );

    print('Scheduled ride fare: ${fareEstimate.formattedTotalFare}');
  } catch (e) {
    print('Error: $e');
  }
}

/// Example 4: Calculate fare with pre-calculated distance and duration
Future<void> exampleFareWithMetrics(BuildContext context) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final token = authProvider.token;

  if (token == null) return;

  try {
    final fareEstimate = await FareService.calculateFareWithMetrics(
      authToken: token,
      pickupLat: 51.5074,
      pickupLng: -0.1278,
      pickupAddress: '10 Downing Street, London',
      dropoffLat: 51.5194,
      dropoffLng: -0.1270,
      dropoffAddress: 'King\'s Cross Station, London',
      distanceMi: 2.5, // Pre-calculated distance in miles
      durationMin: 15.0, // Pre-calculated duration in minutes
      scheduleType: 'asap',
    );

    print('Fare: ${fareEstimate.formattedTotalFare}');
  } catch (e) {
    print('Error: $e');
  }
}

/// Example 5: Use in MapScreen to calculate fare when both locations are selected
class MapScreenWithFareExample extends StatefulWidget {
  const MapScreenWithFareExample({super.key});

  @override
  State<MapScreenWithFareExample> createState() =>
      _MapScreenWithFareExampleState();
}

class _MapScreenWithFareExampleState extends State<MapScreenWithFareExample> {
  String? _pickupAddress;
  double? _pickupLat;
  double? _pickupLng;
  String? _destinationAddress;
  double? _destinationLat;
  double? _destinationLng;
  FareEstimate? _fareEstimate;
  bool _isCalculatingFare = false;

  Future<void> _calculateFare() async {
    if (_pickupLat == null ||
        _pickupLng == null ||
        _destinationLat == null ||
        _destinationLng == null ||
        _pickupAddress == null ||
        _destinationAddress == null) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to calculate fare')),
      );
      return;
    }

    setState(() {
      _isCalculatingFare = true;
    });

    try {
      final fare = await FareService.calculateFare(
        authToken: token,
        pickupLat: _pickupLat!,
        pickupLng: _pickupLng!,
        pickupAddress: _pickupAddress!,
        dropoffLat: _destinationLat!,
        dropoffLng: _destinationLng!,
        dropoffAddress: _destinationAddress!,
        scheduleType: 'asap',
      );

      setState(() {
        _fareEstimate = fare;
        _isCalculatingFare = false;
      });
    } catch (e) {
      setState(() {
        _isCalculatingFare = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error calculating fare: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Ride')),
      body: Column(
        children: [
          // Location inputs would go here

          // Show fare estimate
          if (_fareEstimate != null)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Estimated Fare: ${_fareEstimate!.formattedTotalFare}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Distance: ${_fareEstimate!.formattedDistance}'),
                  Text('Duration: ${_fareEstimate!.formattedDuration}'),
                ],
              ),
            ),

          // Calculate button
          if (_pickupLat != null && _destinationLat != null)
            ElevatedButton(
              onPressed: _isCalculatingFare ? null : _calculateFare,
              child:
                  _isCalculatingFare
                      ? const CircularProgressIndicator()
                      : const Text('Calculate Fare'),
            ),
        ],
      ),
    );
  }
}
