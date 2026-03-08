import 'location_model.dart';
import 'driver.dart';

class Booking {
  final int? id;
  final String? bookingNumber;
  final String status;
  final int fleetId;
  final String? fleetType;
  final List<LocationModel> locations;
  final DateTime? bookingTime;
  final String scheduleType;
  final double? fare;
  final double? distanceMi;
  final double? durationMin;
  final String? paymentMethod;
  final String? notes;
  final Driver? driver;
  final DateTime? createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  Booking({
    this.id,
    this.bookingNumber,
    required this.status,
    required this.fleetId,
    this.fleetType,
    required this.locations,
    this.bookingTime,
    this.scheduleType = 'asap',
    this.fare,
    this.distanceMi,
    this.durationMin,
    this.paymentMethod,
    this.notes,
    this.driver,
    this.createdAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Backend returns bk_-prefixed column names; fallback to clean keys for internal use
    final isBkFormat = json.containsKey('bk_id') || json.containsKey('bk_status');

    double? parseFare(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString().replaceAll(',', ''));
    }

    // Build locations list
    List<LocationModel> locations;
    if (json['locations'] != null) {
      locations = (json['locations'] as List<dynamic>)
          .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (isBkFormat) {
      // Construct from individual pickup/dropoff fields
      locations = [];
      if (json['bk_pickup_location'] != null) {
        locations.add(LocationModel(
          lat: double.tryParse(json['bk_pickup_lat']?.toString() ?? '') ?? 0,
          lng: double.tryParse(json['bk_pickup_lng']?.toString() ?? '') ?? 0,
          address: json['bk_pickup_location'] as String,
          type: 'pickup',
        ));
      }
      if (json['bk_dropoff_location'] != null) {
        locations.add(LocationModel(
          lat: double.tryParse(json['bk_dropoff_lat']?.toString() ?? '') ?? 0,
          lng: double.tryParse(json['bk_dropoff_lng']?.toString() ?? '') ?? 0,
          address: json['bk_dropoff_location'] as String,
          type: 'dropoff',
        ));
      }
    } else {
      locations = [];
    }

    return Booking(
      id: (json['bk_id'] ?? json['id']) as int?,
      bookingNumber: json['booking_number'] as String?,
      status: (json['bk_status'] ?? json['status'] ?? 'unknown') as String,
      fleetId: ((json['bk_fleet_type'] ?? json['fleet_id']) as num?)?.toInt() ?? 0,
      fleetType: json['fleet_type'] as String?,
      locations: locations,
      bookingTime: () {
        final raw = json['bk_bookingtime'] ?? json['booking_time'];
        if (raw == null) return null;
        return DateTime.tryParse(raw.toString());
      }(),
      scheduleType: json['schedule_type'] as String? ?? 'asap',
      fare: parseFare(json['bk_total'] ?? json['bk_fare'] ?? json['fare']),
      distanceMi: parseFare(json['bk_distance'] ?? json['distance_mi']),
      durationMin: null,
      paymentMethod: (json['bk_payment_method'] ?? json['payment_method']) as String?,
      notes: (json['bk_booking_notes'] ?? json['notes']) as String?,
      driver: json['driver'] != null
          ? Driver.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'].toString())
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.tryParse(json['cancelled_at'].toString())
          : null,
      cancellationReason: json['cancellation_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (bookingNumber != null) 'booking_number': bookingNumber,
      'status': status,
      'fleet_id': fleetId,
      if (fleetType != null) 'fleet_type': fleetType,
      'locations': locations.map((e) => e.toJson()).toList(),
      if (bookingTime != null) 'booking_time': bookingTime!.toIso8601String(),
      'schedule_type': scheduleType,
      if (fare != null) 'fare': fare,
      if (distanceMi != null) 'distance_mi': distanceMi,
      if (durationMin != null) 'duration_min': durationMin,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (notes != null) 'notes': notes,
      if (driver != null) 'driver': driver!.toJson(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (startedAt != null) 'started_at': startedAt!.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
      if (cancelledAt != null) 'cancelled_at': cancelledAt!.toIso8601String(),
      if (cancellationReason != null) 'cancellation_reason': cancellationReason,
    };
  }

  String get pickupAddress {
    final pickup = locations.firstWhere(
      (loc) => loc.type == 'pickup',
      orElse: () => locations.first,
    );
    return pickup.address;
  }

  String get dropoffAddress {
    final dropoff = locations.firstWhere(
      (loc) => loc.type == 'dropoff',
      orElse: () => locations.last,
    );
    return dropoff.address;
  }

  List<LocationModel> get stops {
    return locations.where((loc) => loc.type == 'stop').toList();
  }

  bool get hasDriver => driver != null;
  
  bool get isActive => 
      status == 'pending' || 
      status == 'searching_driver' || 
      status == 'driver_assigned' || 
      status == 'driver_arrived' || 
      status == 'ride_started';
  
  bool get isCompleted => status == 'completed';
  
  bool get isCancelled => status == 'cancelled';
}
