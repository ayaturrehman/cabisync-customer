import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cabisync_customer/providers/auth_provider.dart';
import 'package:cabisync_customer/screens/home/route_editor_screen.dart';
import 'package:cabisync_customer/services/pickup_lookup_session.dart';
import 'package:cabisync_customer/services/google_places_service.dart';

void main() {
  final position = Position.fromMap({'latitude': 51.0, 'longitude': -1.0,
    'timestamp': DateTime(2026).millisecondsSinceEpoch, 'accuracy': 1.0,
    'altitude': 0.0, 'heading': 0.0, 'speed': 0.0, 'speed_accuracy': 0.0});
  Widget screen(PickupLookupSession lookup) => ChangeNotifierProvider(
    create: (_) => AuthProvider(), child: MaterialApp(home: RouteEditorScreen(
      currentPosition: position, pickupLookup: lookup)));
  testWidgets('missing address unlocks manual pickup instead of endless spinner', (tester) async {
    await tester.pumpWidget(screen(PickupLookupSession(lookup: (_, _) async => null)));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(TextField), findsNWidgets(2));
  });
  testWidgets('stalled address request times out and screen can be closed safely', (tester) async {
    final result = Completer<PlaceDetails?>();
    await tester.pumpWidget(screen(PickupLookupSession(lookup: (_, _) => result.future)));
    await tester.pump();
    await tester.pump(const Duration(seconds: 11));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    result.complete(null);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
