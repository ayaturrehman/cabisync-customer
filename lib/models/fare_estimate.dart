class FareEstimate {
  final String? fleetId;
  final String? fleetType;
  final double totalPrice;
  final double distanceInMiles;
  final double duration;
  final String currency;
  final Map<String, dynamic>? breakdown;

  // Legacy fields for backward compatibility
  final double? baseFare;
  final double? distanceFare;
  final double? durationFare;

  FareEstimate({
    this.fleetId,
    this.fleetType,
    required this.totalPrice,
    required this.distanceInMiles,
    required this.duration,
    this.currency = 'GBP',
    this.breakdown,
    this.baseFare,
    this.distanceFare,
    this.durationFare,
  });

  factory FareEstimate.fromJson(Map<String, dynamic> json) {
    // Parse distance - handle both string ("28.23 miles") and number
    double parseDistance(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        // Remove " miles" or " mi" suffix if present
        final cleaned =
            value.replaceAll(RegExp(r'\s*(miles?|mi)\s*$'), '').trim();
        return double.tryParse(cleaned) ?? 0.0;
      }
      return 0.0;
    }

    // Parse price - handle both string and number
    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    // Parse duration - handle both string ("42 minutes") and number
    double parseDuration(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();

      if (value is String) {
        // Handle "42 minutes" format
        final minutesMatch = RegExp(r'(\d+)\s*minutes?').firstMatch(value);
        if (minutesMatch != null) {
          return double.parse(minutesMatch.group(1)!);
        }

        // Handle "1 hours 8 minutes" format
        double totalMinutes = 0.0;
        final hoursMatch = RegExp(r'(\d+)\s*hours?').firstMatch(value);
        if (hoursMatch != null) {
          totalMinutes += double.parse(hoursMatch.group(1)!) * 60;
        }
        final minsMatch = RegExp(r'(\d+)\s*minutes?').firstMatch(value);
        if (minsMatch != null) {
          totalMinutes += double.parse(minsMatch.group(1)!);
        }

        return totalMinutes > 0 ? totalMinutes : 0.0;
      }

      return 0.0;
    }

    return FareEstimate(
      fleetId: json['fleet_id'] as String?,
      fleetType: json['fleet_type'] as String?,
      totalPrice: parsePrice(json['total_price']),
      distanceInMiles: parseDistance(json['distance']),
      duration: parseDuration(json['duration']),
      currency: json['currency'] ?? 'USD',
      breakdown: json['breakdown'] as Map<String, dynamic>?,
      baseFare: parsePrice(json['base_fare']),
      distanceFare: parsePrice(json['distance_fare']),
      durationFare: parsePrice(json['duration_fare']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (fleetId != null) 'fleet_id': fleetId,
      if (fleetType != null) 'fleet_type': fleetType,
      'total_price': totalPrice,
      'distance_in_miles': distanceInMiles,
      'duration': duration,
      'currency': currency,
      if (breakdown != null) 'breakdown': breakdown,
      if (baseFare != null) 'base_fare': baseFare,
      if (distanceFare != null) 'distance_fare': distanceFare,
      if (durationFare != null) 'duration_fare': durationFare,
    };
  }

  String get formattedTotalFare {
    return '£${totalPrice.toStringAsFixed(2)}';
  }

  String get formattedDistance {
    return '${distanceInMiles.toStringAsFixed(1)} mi';
  }

  String get formattedDuration {
    final hours = duration ~/ 60;
    final mins = duration % 60;
    if (hours > 0) {
      return '${hours}h ${mins.toInt()}m';
    }
    return '${mins.toInt()}m';
  }

  @override
  String toString() {
    return 'FareEstimate{fleetId: $fleetId, fleetType: $fleetType, totalPrice: $formattedTotalFare, distance: $formattedDistance, duration: $formattedDuration}';
  }
}
