import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'journey_route_service.dart';

/// Holds the displayed route for one booking flow, without disk caching.
class JourneyRouteSession {
  final Future<List<LatLng>> Function(List<LatLng>) _fetch;
  String? _key;
  Future<List<LatLng>>? _pending;
  JourneyRouteSession({Future<List<LatLng>> Function(List<LatLng>)? fetch})
    : _fetch = fetch ?? JourneyRouteService().route;

  Future<List<LatLng>> route(List<LatLng> points) {
    final key = points.map((p) => '${p.latitude},${p.longitude}').join(';');
    if (_key == key && _pending != null) return _pending!;
    _key = key;
    final future = _fetch(List.unmodifiable(points));
    _pending = future;
    return future.catchError((Object error) {
      if (identical(_pending, future)) {
        _key = null;
        _pending = null;
      }
      throw error;
    });
  }
}
