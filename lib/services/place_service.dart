import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../widgets/place_autocomplete_input.dart';

class PlaceService {
  static Future<List<PlaceSuggestion>> fetchPredictions(String input) async {
    if (AppConfig.googleApiKey.isEmpty || input.isEmpty || input.length < 3) {
      return [];
    }

    final url = Uri.parse(
      'https://places.googleapis.com/v1/places:autocomplete?key=${AppConfig.googleApiKey}',
    );

    final body = jsonEncode({
      'input': input,
      'includedRegionCodes': ['GB'],
    });

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception('Autocomplete failed: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    // print('Autocomplete response: ${res.body}');
    final suggestions =
        (data['predictions'] ?? data['suggestions'] ?? []) as List;

    return suggestions.map((s) {
      final prediction = s['placePrediction'] ?? {};

      final placeId = prediction['placeId'] ?? '';
      final display =
          prediction['structuredFormat']?['mainText']?['text'] ?? '';
      final desc =
          s['description'] ??
          prediction['structuredFormat']?['secondaryText']['text'] ??
          '';
      print('Suggestion: $placeId, $desc, $display');
      return PlaceSuggestion(id: placeId, description: desc, display: display);
    }).toList();
  }

  static Future<PlaceDetail> fetchPlaceDetail(
    PlaceSuggestion suggestion,
  ) async {
    final url = Uri.parse(
      'https://places.googleapis.com/v1/places/${suggestion.id}'
      '?key=${AppConfig.googleApiKey}&fields=formattedAddress,location,displayName',
    );

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Place detail failed: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final name = data['displayName']?['text'] ?? suggestion.display;
    final address = data['formattedAddress'] ?? suggestion.display;
    final lat = (data['location']?['latitude'] as num?)?.toDouble();
    final lng = (data['location']?['longitude'] as num?)?.toDouble();

    return PlaceDetail(name: name, address: address, lat: lat, lng: lng);
  }
}
