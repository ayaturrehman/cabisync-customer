import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cabisync_customer/providers/auth_provider.dart';
import 'package:cabisync_customer/screens/home/route_editor_screen.dart';
import 'package:cabisync_customer/screens/booking/ride_booking_screen.dart';
import 'package:cabisync_customer/services/pickup_lookup_session.dart';
import 'package:cabisync_customer/services/places_search_session.dart';
import 'package:cabisync_customer/services/google_places_service.dart';

void main() {
  final position = Position.fromMap({
    'latitude': 51.0,
    'longitude': -1.0,
    'timestamp': DateTime(2026).millisecondsSinceEpoch,
    'accuracy': 1.0,
    'altitude': 0.0,
    'heading': 0.0,
    'speed': 0.0,
    'speed_accuracy': 0.0,
  });
  PlaceDetails place(String name) => PlaceDetails(
    placeId: name,
    name: name,
    formattedAddress: '$name address',
    latitude: 51,
    longitude: -1,
  );
  PlacePrediction prediction(String name) => PlacePrediction(
    placeId: name,
    description: name,
    mainText: name,
    secondaryText: '$name address',
  );
  Widget screen(PlacesSearchSession Function() factory) =>
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: MaterialApp(
          home: RouteEditorScreen(
            currentPosition: position,
            pickupLookup: PickupLookupSession(
              lookup: (_, _) async => place('Pickup'),
            ),
            searchSessionFactory: factory,
          ),
        ),
      );

  testWidgets('late destination response cannot overwrite pickup results', (
    tester,
  ) async {
    final requests = <String, Completer<List<PlacePrediction>>>{};
    await tester.pumpWidget(
      screen(
        () => PlacesSearchSession(
          search: (query, token) {
            return (requests[query] = Completer()).future;
          },
        ),
      ),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(1), 'London');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.enterText(find.byType(TextField).at(0), 'Oxford');
    await tester.pump(const Duration(milliseconds: 600));
    requests['Oxford']!.complete([prediction('Oxford result')]);
    await tester.pump();
    requests['London']!.complete([prediction('London result')]);
    await tester.pump();
    expect(find.text('Oxford result'), findsOneWidget);
    expect(find.text('London result'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('edited destination cannot book using old selected coordinates', (
    tester,
  ) async {
    await tester.pumpWidget(
      screen(
        () => PlacesSearchSession(
          search: (_, _) async => [prediction('Station')],
          details: (_, _) async => place('Station'),
        ),
      ),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(1), 'Station');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    await tester.tap(find.text('Station').last);
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(1), 'St');
    await tester.tap(find.text('See rides'));
    await tester.pump();
    expect(find.byType(RideBookingScreen), findsNothing);
    expect(find.text('Please select pickup and destination'), findsOneWidget);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
  });
}
