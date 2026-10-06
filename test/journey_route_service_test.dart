import 'package:flutter_test/flutter_test.dart';
import 'package:cabisync_customer/services/journey_route_service.dart';

void main() {
  test('decodes road geometry preserving point order', () {
    final points = JourneyRouteService.decodePolyline('_p~iF~ps|U_ulLnnqC_mqNvxq`@');
    expect(points.length, 3);
    expect(points.first.latitude, 38.5);
    expect(points.first.longitude, -120.2);
    expect(points.last.latitude, 43.252);
    expect(points.last.longitude, -126.453);
  });
  test('rejects truncated route rather than drawing incorrect geometry', () {
    expect(() => JourneyRouteService.decodePolyline('_p~iF'), throwsFormatException);
  });
  test('empty geometry produces no line', () {
    expect(JourneyRouteService.decodePolyline(''), isEmpty);
  });
}
