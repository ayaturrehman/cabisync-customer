import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cabisync_customer/config/theme.dart';
import 'package:cabisync_customer/widgets/ride_type_card.dart';

void main() {
  testWidgets('selected fare uses blue background without a tick', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: RideTypeCard(
      name: 'Economy', capacity: '', estimatedTime: '4m', price: '£22.45',
      icon: Icons.directions_car, isSelected: true, onTap: () {},
    ))));
    final card = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
    expect((card.decoration as BoxDecoration).color, AppColors.brand);
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.text('£22.45'), findsOneWidget);
  });
}
