import 'package:flutter_test/flutter_test.dart';
import 'package:cabisync_customer/services/places_search_session.dart';

void main() {
  test(
    'skips short queries and repeats, shares token with details then rotates',
    () async {
      final tokens = <String>[];
      String? detailToken;
      final session = PlacesSearchSession(
        search: (query, token) async {
          tokens.add(token);
          return [];
        },
        details: (id, token) async {
          detailToken = token;
          return null;
        },
      );
      await session.predictions('lo');
      expect(tokens, isEmpty);
      await Future.wait([
        session.predictions('London'),
        session.predictions('London'),
      ]);
      await session.predictions('London');
      expect(tokens.length, 1);
      await session.predictions('London station');
      expect(tokens[1], tokens[0]);
      await session.select('station');
      expect(detailToken, tokens[0]);
      await session.predictions('London');
      expect(tokens.last, isNot(tokens.first));
    },
  );
  test('different fields have independent sessions', () async {
    final tokens = <String>[];
    Future<List<Never>> search(String query, String token) async {
      tokens.add(token);
      return [];
    }

    await PlacesSearchSession(search: search).predictions('London');
    await PlacesSearchSession(search: search).predictions('London');
    expect(tokens.first, isNot(tokens.last));
  });
  test('network failure does not prevent retrying same text', () async {
    var requests = 0;
    final session = PlacesSearchSession(
      search: (query, token) async {
        if (++requests == 1) throw Exception('offline');
        return [];
      },
    );
    await expectLater(session.predictions('London'), throwsException);
    await session.predictions('London');
    expect(requests, 2);
  });
}
