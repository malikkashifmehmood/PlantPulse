import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PlantPulse test environment works', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('PlantPulse'))),
    );

    expect(find.text('PlantPulse'), findsOneWidget);
  });
}
