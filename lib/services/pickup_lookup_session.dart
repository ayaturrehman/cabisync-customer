import 'google_places_service.dart';

/// Reuses the current pickup lookup while editing one booking flow.
class PickupLookupSession {
  final Future<PlaceDetails?> Function(double, double) _lookup;
  final DateTime Function() _now;
  String? _key;
  DateTime? _started;
  Future<PlaceDetails?>? _result;
  PickupLookupSession({
    Future<PlaceDetails?> Function(double, double)? lookup,
    DateTime Function()? now,
  }) : _lookup = lookup ?? GooglePlacesService.reverseGeocode,
       _now = now ?? DateTime.now;

  Future<PlaceDetails?> lookup(double lat, double lng) {
    final key = '$lat,$lng';
    final now = _now();
    if (_key == key &&
        _result != null &&
        _started != null &&
        now.difference(_started!) < const Duration(minutes: 5))
      return _result!;
    _key = key;
    _started = now;
    final request = _lookup(lat, lng);
    _result = request;
    return request.then(
      (value) {
        if (value == null && identical(_result, request)) _result = null;
        return value;
      },
      onError: (Object error) {
        if (identical(_result, request)) _result = null;
        throw error;
      },
    );
  }
}
