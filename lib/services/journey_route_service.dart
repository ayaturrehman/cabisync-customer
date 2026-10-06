import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class JourneyRouteService {
  Future<List<LatLng>> route(List<LatLng> points) async {
    if (points.length < 2) return [];
    String coordinate(LatLng point) => '${point.latitude},${point.longitude}';
    final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': coordinate(points.first),
      'destination': coordinate(points.last),
      'mode': 'driving',
      if (points.length > 2)
        'waypoints': points
            .sublist(1, points.length - 1)
            .map(coordinate)
            .join('|'),
      'key': AppConfig.googleApiKey,
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) throw Exception('Route unavailable');
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['status'] != 'OK') throw Exception('Route unavailable');
    final routes = body['routes'] as List;
    return decodePolyline(
      routes.first['overview_polyline']['points'] as String,
    );
  }

  static List<LatLng> decodePolyline(String encoded) {
    final points = <LatLng>[];
    var index = 0, latitude = 0, longitude = 0;
    int readDelta() {
      var result = 0, shift = 0, byte = 0;
      do {
        if (index >= encoded.length || shift > 30) {
          throw const FormatException('Invalid route geometry');
        }
        byte = encoded.codeUnitAt(index++) - 63;
        if (byte < 0 || byte > 63)
          throw const FormatException('Invalid route geometry');
        result |= (byte & 31) << shift;
        shift += 5;
      } while (byte >= 32);
      return (result & 1) != 0 ? ~(result >> 1) : result >> 1;
    }

    while (index < encoded.length) {
      latitude += readDelta();
      longitude += readDelta();
      points.add(LatLng(latitude / 1e5, longitude / 1e5));
    }
    return points;
  }
}
