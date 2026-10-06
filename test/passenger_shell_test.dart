import 'package:cabisync_customer/widgets/passenger_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tabs load on first visit and preserve the booking form', (
    tester,
  ) async {
    var tripBuilds = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: PassengerShell(
          pages: [
            (_) => const Scaffold(body: TextField()),
            (_) {
              tripBuilds++;
              return const Text('Trip history');
            },
            (_) => const Text('Passenger account'),
          ],
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Doncaster station');
    expect(tripBuilds, 0);
    await tester.tap(find.text('Trips'));
    await tester.pumpAndSettle();
    expect(find.text('Trip history'), findsOneWidget);
    expect(tripBuilds, 1);
    await tester.tap(find.text('Book'));
    await tester.pumpAndSettle();
    expect(find.text('Doncaster station'), findsOneWidget);
    await tester.tap(find.text('Trips'));
    await tester.pumpAndSettle();
    expect(tripBuilds, 1);
  });
}
