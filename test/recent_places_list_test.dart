import 'package:cabisync_customer/services/google_places_service.dart';
import 'package:cabisync_customer/widgets/recent_places_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('recent-place tap reuses the saved coordinates', (tester) async {
    final place = PlaceDetails(
      placeId: 'station',
      name: 'Station',
      formattedAddress: 'Station Road, Doncaster, UK',
      latitude: 53.52,
      longitude: -1.14,
    );
    PlaceDetails? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecentPlacesList(
            places: [place],
            onSelected: (value) => selected = value,
          ),
        ),
      ),
    );
    expect(find.text('Recent places'), findsOneWidget);
    await tester.tap(find.text('Station'));
    expect(selected?.latitude, 53.52);
    expect(selected?.longitude, -1.14);
  });
}
