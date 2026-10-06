import 'dart:math';
import 'google_places_service.dart';

class PlacesSearchSession {
  String? _token;
  String? _query;
  Future<List<PlacePrediction>>? _results;
  final Future<List<PlacePrediction>> Function(String, String) _search;
  final Future<PlaceDetails?> Function(String, String?) _details;

  PlacesSearchSession({
    Future<List<PlacePrediction>> Function(String, String)? search,
    Future<PlaceDetails?> Function(String, String?)? details,
  }) : _search =
           search ??
           ((query, token) => GooglePlacesService.getPlacePredictions(
             query,
             sessionToken: token,
           )),
       _details =
           details ??
           ((id, token) =>
               GooglePlacesService.getPlaceDetails(id, sessionToken: token));

  String _newToken() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  Future<List<PlacePrediction>> predictions(String input) {
    final query = input.trim();
    if (query.length < 3) {
      _query = null;
      _results = null;
      return Future.value([]);
    }
    if (_query == query && _results != null) return _results!;
    _token ??= _newToken();
    _query = query;
    final request = _search(query, _token!);
    _results = request;
    return request.catchError((Object error) {
      if (identical(_results, request)) {
        _query = null;
        _results = null;
      }
      throw error;
    });
  }

  Future<PlaceDetails?> select(String placeId) {
    final token = _token;
    reset();
    return _details(placeId, token);
  }

  void reset() {
    _token = null;
    _query = null;
    _results = null;
  }
}
