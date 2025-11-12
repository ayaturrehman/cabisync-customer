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
    return Booking(
      id: json['id'] as int?,
      bookingNumber: json['booking_number'] as String?,
      status: json['status'] as String,
      fleetId: json['fleet_id'] as int,
      fleetType: json['fleet_type'] as String?,
      locations: (json['locations'] as List<dynamic>?)
              ?.map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bookingTime: json['booking_time'] != null
          ? DateTime.parse(json['booking_time'] as String)
          : null,
      scheduleType: json['schedule_type'] as String? ?? 'asap',
      fare: json['fare'] != null ? (json['fare'] as num).toDouble() : null,
      distanceMi: json['distance_mi'] != null
          ? (json['distance_mi'] as num).toDouble()
          : null,
      durationMin: json['duration_min'] != null
          ? (json['duration_min'] as num).toDouble()
          : null,
      paymentMethod: json['payment_method'] as String?,
      notes: json['notes'] as String?,
      driver: json['driver'] != null
          ? Driver.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
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
