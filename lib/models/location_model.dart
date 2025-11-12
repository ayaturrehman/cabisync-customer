class LocationModel {
  final double lat;
  final double lng;
  final String address;
  final String type; // 'pickup', 'stop', 'dropoff'

  LocationModel({
    required this.lat,
    required this.lng,
    required this.address,
    required this.type,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      address: json['address'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'address': address,
      'type': type,
    };
  }

  LocationModel copyWith({
    double? lat,
    double? lng,
    String? address,
    String? type,
  }) {
    return LocationModel(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
      type: type ?? this.type,
    );
  }
}

class SavedLocation {
  final int? id;
  final String label;
  final double lat;
  final double lng;
  final String address;

  SavedLocation({
    this.id,
    required this.label,
    required this.lat,
    required this.lng,
    required this.address,
  });

  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    return SavedLocation(
      id: json['id'] as int?,
      label: json['label'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'label': label,
      'lat': lat,
      'lng': lng,
      'address': address,
    };
  }
}
