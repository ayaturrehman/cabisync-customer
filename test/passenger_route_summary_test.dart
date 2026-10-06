import 'package:cabisync_customer/widgets/route_visualization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'journey labels and long addresses remain visible with larger text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const pickup =
          'Doncaster Railway Station, Station Court, Doncaster, United Kingdom';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: RouteVisualization(
                  pickup: pickup,
                  dropoff: 'Airport Way, Luton LU2 9LY, United Kingdom',
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Pickup'), findsOneWidget);
      expect(find.text('Destination'), findsOneWidget);
      expect(find.text(pickup), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
