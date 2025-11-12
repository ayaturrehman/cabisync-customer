class Fleet {
  final int fleetId;
  final String fleetType;
  final String? description;
  final int? capacity;
  final String? icon;
  final bool isAvailable;
  final FarePricing? pricing;

  Fleet({
    required this.fleetId,
    required this.fleetType,
    this.description,
    this.capacity,
    this.icon,
    this.isAvailable = true,
    this.pricing,
  });

  factory Fleet.fromJson(Map<String, dynamic> json) {
    return Fleet(
      fleetId: json['fleet_id'] as int,
      fleetType: json['fleet_type'] as String,
      description: json['description'] as String?,
      capacity: json['capacity'] as int?,
      icon: json['icon'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      pricing: json['pricing'] != null 
          ? FarePricing.fromJson(json['pricing'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fleet_id': fleetId,
      'fleet_type': fleetType,
      'description': description,
      'capacity': capacity,
      'icon': icon,
      'is_available': isAvailable,
      'pricing': pricing?.toJson(),
    };
  }
}

class FarePricing {
  final double distanceFare;
  final double timeFare;
  final double baseFare;
  final double serviceFee;
  final double tax;
  final double totalPrice;
  final double? distanceMi;
  final double? durationMin;

  FarePricing({
    required this.distanceFare,
    required this.timeFare,
    required this.baseFare,
    required this.serviceFee,
    required this.tax,
    required this.totalPrice,
    this.distanceMi,
    this.durationMin,
  });

  factory FarePricing.fromJson(Map<String, dynamic> json) {
    return FarePricing(
      distanceFare: (json['distance_fare'] as num).toDouble(),
      timeFare: (json['time_fare'] as num).toDouble(),
      baseFare: (json['base_fare'] as num).toDouble(),
      serviceFee: (json['service_fee'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      distanceMi: json['distance_mi'] != null 
          ? (json['distance_mi'] as num).toDouble() 
          : null,
      durationMin: json['duration_min'] != null 
          ? (json['duration_min'] as num).toDouble() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distance_fare': distanceFare,
      'time_fare': timeFare,
      'base_fare': baseFare,
      'service_fee': serviceFee,
      'tax': tax,
      'total_price': totalPrice,
      'distance_mi': distanceMi,
      'duration_min': durationMin,
    };
  }

  String get estimatedTime {
    if (durationMin == null) return 'N/A';
    if (durationMin! < 60) return '${durationMin!.round()} min';
    final hours = (durationMin! / 60).floor();
    final minutes = (durationMin! % 60).round();
    return '${hours}h ${minutes}min';
  }
}
