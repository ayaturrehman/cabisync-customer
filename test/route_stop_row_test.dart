import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cabisync_customer/widgets/route_stop_row.dart';
import 'package:cabisync_customer/providers/auth_provider.dart';
import 'package:cabisync_customer/screens/home/route_editor_screen.dart';

void main() {
  testWidgets('add stop stays inline with pickup and destination', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const MaterialApp(home: RouteEditorScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(seconds: 4));
    final initialFields = find.byType(TextField).evaluate().length;
    await tester.tap(find.text('+ Add stop'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(TextField), findsNWidgets(initialFields + 1));
    expect(find.text('Your route'), findsOneWidget);
    expect(find.text('Stop 1'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    await tester.tap(find.byTooltip('Remove stop 1'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(TextField), findsNWidgets(initialFields));
  });
  testWidgets('stop controls move and remove, boundary direction disabled', (
    tester,
  ) async {
    var down = 0, removed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RouteStopRow(
            address: 'Station Court',
            number: 1,
            onMoveDown: () => down++,
            onRemove: () => removed++,
          ),
        ),
      ),
    );
    final up = tester.widget<IconButton>(find.byWidgetPredicate((widget) => widget is IconButton && widget.tooltip == 'Move stop 1 up'));
    expect(up.onPressed, isNull);
    await tester.tap(find.byTooltip('Move stop 1 down'));
    await tester.tap(find.byTooltip('Remove stop 1'));
    expect(down, 1);
    expect(removed, 1);
    expect(tester.takeException(), isNull);
  });
}
