import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'google_places_service.dart';

/// Account-scoped address history stored with the app's encrypted local data.
class RecentPlacesStore {
  RecentPlacesStore({
    Future<String?> Function(String)? read,
    Future<void> Function(String, String)? write,
  }) : _read = read ?? ((key) => _storage.read(key: key)),
       _write =
           write ?? ((key, value) => _storage.write(key: key, value: value));

  static const _storage = FlutterSecureStorage();
  static const limit = 8;
  final Future<String?> Function(String) _read;
  final Future<void> Function(String, String) _write;

  static bool usable(PlaceDetails place) {
    final lat = place.latitude;
    final lng = place.longitude;
    return place.formattedAddress.trim().isNotEmpty &&
        lat != null &&
        lng != null &&
        lat.isFinite &&
        lng.isFinite &&
        lat.abs() <= 90 &&
        lng.abs() <= 180 &&
        !(lat == 0 && lng == 0);
  }

  Future<List<PlaceDetails>> load(String userId) async {
    final raw = await _read('recent_places_$userId');
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(PlaceDetails.fromJson)
          .where(usable)
          .take(limit)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<PlaceDetails>> remember(String userId, PlaceDetails place) async {
    final previous = await load(userId);
    if (!usable(place)) return previous;
    final address = place.formattedAddress.trim().toLowerCase();
    final next =
        [
          place,
          ...previous.where(
            (entry) => entry.formattedAddress.trim().toLowerCase() != address,
          ),
        ].take(limit).toList();
    await _write(
      'recent_places_$userId',
      jsonEncode(
        next
            .map(
              (entry) => {
                'place_id': entry.placeId,
                'name': entry.name,
                'formatted_address': entry.formattedAddress,
                'geometry': {
                  'location': {'lat': entry.latitude, 'lng': entry.longitude},
                },
              },
            )
            .toList(),
      ),
    );
    return next;
  }
}
