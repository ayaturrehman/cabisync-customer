class Driver {
  final int id;
  final String name;
  final String phone;
  final String? profilePicture;
  final double rating;
  final int totalRides;
  final Vehicle? vehicle;
  final DriverLocation? currentLocation;

  Driver({
    required this.id,
    required this.name,
    required this.phone,
    this.profilePicture,
    required this.rating,
    required this.totalRides,
    this.vehicle,
    this.currentLocation,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      profilePicture: json['profile_picture'] as String?,
      rating: (json['rating'] as num).toDouble(),
      totalRides: json['total_rides'] as int,
      vehicle: json['vehicle'] != null
          ? Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
      currentLocation: json['current_location'] != null
          ? DriverLocation.fromJson(
              json['current_location'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'profile_picture': profilePicture,
      'rating': rating,
      'total_rides': totalRides,
      'vehicle': vehicle?.toJson(),
      'current_location': currentLocation?.toJson(),
    };
  }
}

class Vehicle {
  final String model;
  final String? color;
  final String plateNumber;
  final int? year;
  final String? make;

  Vehicle({
    required this.model,
    this.color,
    required this.plateNumber,
    this.year,
    this.make,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      model: json['model'] as String,
      color: json['color'] as String?,
      plateNumber: json['plate_number'] as String,
      year: json['year'] as int?,
      make: json['make'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'color': color,
      'plate_number': plateNumber,
      'year': year,
      'make': make,
    };
  }

  String get fullName {
    if (make != null) {
      return '$make $model';
    }
    return model;
  }
}

class DriverLocation {
  final double lat;
  final double lng;
  final double? bearing;
  final DateTime? updatedAt;

  DriverLocation({
    required this.lat,
    required this.lng,
    this.bearing,
    this.updatedAt,
  });

  factory DriverLocation.fromJson(Map<String, dynamic> json) {
    return DriverLocation(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      bearing: json['bearing'] != null ? (json['bearing'] as num).toDouble() : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'bearing': bearing,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
