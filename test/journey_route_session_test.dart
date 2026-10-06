import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cabisync_customer/services/journey_route_session.dart';

void main() {
  const points = [LatLng(51, -1), LatLng(52, -2)];
  test(
    'fare and tracking reuse one request, including simultaneous loads',
    () async {
      var requests = 0;
      final session = JourneyRouteSession(
        fetch: (points) async {
          requests++;
          return points;
        },
      );
      await Future.wait([session.route(points), session.route(points)]);
      await session.route(points);
      expect(requests, 1);
      await session.route([...points, const LatLng(53, -3)]);
      expect(requests, 2);
    },
  );
  test('failed request can be retried', () async {
    var requests = 0;
    final session = JourneyRouteSession(
      fetch: (points) async {
        if (++requests == 1) throw Exception('network');
        return points;
      },
    );
    await expectLater(session.route(points), throwsException);
    await session.route(points);
    expect(requests, 2);
  });
}
