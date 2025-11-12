// Example usage of Fare Calculation API
// This file demonstrates how to use the FareService to calculate ride fares

import '../services/fare_service.dart';

/// Example 1: Calculate fare with all required parameters
Future<void> exampleBasicFareCalculation() async {
  try {
    final fareEstimates = await FareService.calculateFares(
      authToken: 'your_auth_token_here',
      pickupLat: 37.7749,
      pickupLng: -122.4194,
      pickupAddress: '123 Main St, San Francisco, CA',
      dropoffLat: 37.8049,
      dropoffLng: -122.4294,
      dropoffAddress: '456 Oak Ave, San Francisco, CA',
      scheduleType: 'asap', // or 'schedule'
    );

    // Display all fleet options
    for (final fare in fareEstimates) {
      print('Fleet: ${fare.fleetType}');
      print('Base Fare: \$${fare.baseFare}');
      print('Total Price: ${fare.formattedTotalFare}');
      print('Distance: ${fare.formattedDistance}');
      print('Duration: ${fare.formattedDuration}');
      print('---');
    }
  } catch (e) {
    print('Error calculating fare: $e');
  }
}

/// Example 2: Calculate fare with stops
Future<void> exampleFareWithStops() async {
  try {
    final fareEstimates = await FareService.calculateFares(
      authToken: 'your_auth_token_here',
      pickupLat: 37.7749,
      pickupLng: -122.4194,
      pickupAddress: '123 Main St, San Francisco, CA',
      dropoffLat: 37.8049,
      dropoffLng: -122.4294,
      dropoffAddress: '456 Oak Ave, San Francisco, CA',
      stops: [
        {
          'lat': 37.7849,
          'lng': 37.7849,
          'address': '789 Stop St, San Francisco, CA',
        },
      ],
      scheduleType: 'asap',
    );

    print('Fare options with 1 stop:');
    for (final fare in fareEstimates) {
      print('${fare.fleetType}: ${fare.formattedTotalFare}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

/// Example 3: Calculate fare for scheduled ride
Future<void> exampleScheduledRide() async {
  try {
    // Schedule for tomorrow at 9 AM
    final scheduledTime = DateTime.now().add(const Duration(days: 1));
    final scheduledDateTime = DateTime(
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      9,
      0,
    );

    final fareEstimates = await FareService.calculateFares(
      authToken: 'your_auth_token_here',
      pickupLat: 37.7749,
      pickupLng: -122.4194,
      pickupAddress: '123 Main St, San Francisco, CA',
      dropoffLat: 37.8049,
      dropoffLng: -122.4294,
      dropoffAddress: '456 Oak Ave, San Francisco, CA',
      bookingTime: scheduledDateTime.toIso8601String(),
      scheduleType: 'schedule',
    );

    print('Fare for scheduled ride:');
    for (final fare in fareEstimates) {
      print('${fare.fleetType}: ${fare.formattedTotalFare}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

/// Example 4: Calculate fare with pre-calculated distance and duration
Future<void> exampleWithMetrics() async {
  try {
    final fareEstimates = await FareService.calculateFaresWithMetrics(
      authToken: 'your_auth_token_here',
      pickupLat: 37.7749,
      pickupLng: -122.4194,
      pickupAddress: '123 Main St, San Francisco, CA',
      dropoffLat: 37.8049,
      dropoffLng: -122.4294,
      dropoffAddress: '456 Oak Ave, San Francisco, CA',
      distanceMi: 28.23,
      durationMin: 42,
      scheduleType: 'asap',
    );

    print('Fare with pre-calculated metrics:');
    for (final fare in fareEstimates) {
      print('${fare.fleetType}: ${fare.formattedTotalFare}');
      print('  Distance: ${fare.formattedDistance}');
      print('  Duration: ${fare.formattedDuration}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

/// Example 5: Handle response data
Future<void> exampleResponseHandling() async {
  try {
    final fareEstimates = await FareService.calculateFares(
      authToken: 'your_auth_token_here',
      pickupLat: 37.7749,
      pickupLng: -122.4194,
      pickupAddress: '123 Main St, San Francisco, CA',
      dropoffLat: 37.8049,
      dropoffLng: -122.4294,
      dropoffAddress: '456 Oak Ave, San Francisco, CA',
    );

    if (fareEstimates.isEmpty) {
      print('No fare options available');
      return;
    }

    // Find cheapest option
    final cheapest = fareEstimates.reduce(
      (a, b) => a.totalPrice < b.totalPrice ? a : b,
    );
    print('Cheapest: ${cheapest.fleetType} - ${cheapest.formattedTotalFare}');

    // Find most expensive option
    final mostExpensive = fareEstimates.reduce(
      (a, b) => a.totalPrice > b.totalPrice ? a : b,
    );
    print(
      'Most Expensive: ${mostExpensive.fleetType} - ${mostExpensive.formattedTotalFare}',
    );

    // Display all options sorted by price
    fareEstimates.sort((a, b) => a.totalPrice.compareTo(b.totalPrice));
    print('\nAll options (sorted by price):');
    for (final fare in fareEstimates) {
      print('  ${fare.fleetType}: ${fare.formattedTotalFare}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
