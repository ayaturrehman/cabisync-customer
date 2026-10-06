import 'package:flutter_test/flutter_test.dart';
import 'package:cabisync_customer/services/google_places_service.dart';
import 'package:cabisync_customer/services/pickup_lookup_session.dart';

void main() {
  test(
    'reuses unchanged pickup, refreshes changed or expired coordinates',
    () async {
      var calls = 0;
      var now = DateTime(2026);
      final session = PickupLookupSession(
        now: () => now,
        lookup: (lat, lng) async {
          calls++;
          return PlaceDetails(
            placeId: 'pickup',
            name: 'Pickup',
            formattedAddress: 'Pickup',
            latitude: lat,
            longitude: lng,
          );
        },
      );
      await Future.wait([session.lookup(51, -1), session.lookup(51, -1)]);
      await session.lookup(51, -1);
      expect(calls, 1);
      await session.lookup(52, -1);
      expect(calls, 2);
      now = now.add(const Duration(minutes: 6));
      await session.lookup(52, -1);
      expect(calls, 3);
    },
  );
  test('missing result allows another attempt', () async {
    var calls = 0;
    final session = PickupLookupSession(
      lookup: (lat, lng) async {
        calls++;
        return null;
      },
    );
    await session.lookup(51, -1);
    await session.lookup(51, -1);
    expect(calls, 2);
  });
}
