import 'package:cabisync_customer/services/google_places_service.dart';
import 'package:cabisync_customer/services/recent_places_store.dart';
import 'package:flutter_test/flutter_test.dart';

PlaceDetails place(String name, {double latitude = 53.52}) => PlaceDetails(
  placeId: name,
  name: name,
  formattedAddress: name,
  latitude: latitude,
  longitude: -1.14,
);

void main() {
  late Map<String, String> storage;
  late RecentPlacesStore store;
  setUp(() {
    storage = {};
    store = RecentPlacesStore(
      read: (key) async => storage[key],
      write: (key, value) async {
        storage[key] = value;
      },
    );
  });
  test(
    'history survives reopening, retains coordinates and is isolated by account',
    () async {
      await store.remember('1', place('Station'));
      final reopened = RecentPlacesStore(
        read: (key) async => storage[key],
        write: (key, value) async {
          storage[key] = value;
        },
      );
      final history = await reopened.load('1');
      expect(history.single.name, 'Station');
      expect(history.single.latitude, 53.52);
      expect(history.single.longitude, -1.14);
      expect(await reopened.load('2'), isEmpty);
    },
  );
  test(
    'selected place moves to front without duplicates and history stays bounded',
    () async {
      for (var i = 0; i < 12; i++) {
        await store.remember('1', place('Place $i'));
      }
      await store.remember('1', place(' place 6 '));
      final history = await store.load('1');
      expect(history.length, RecentPlacesStore.limit);
      expect(history.first.name, ' place 6 ');
      expect(
        history.where((p) => p.name.trim().toLowerCase() == 'place 6').length,
        1,
      );
    },
  );
  test(
    'invalid coordinates and corrupt history do not become pickup options',
    () async {
      await store.remember('1', place('Invalid', latitude: 100));
      expect(await store.load('1'), isEmpty);
      storage['recent_places_1'] = '{broken';
      expect(await store.load('1'), isEmpty);
      storage['recent_places_1'] = '[{"geometry":"broken"}]';
      expect(await store.load('1'), isEmpty);
    },
  );
}
