import 'package:flutter_test/flutter_test.dart';

import 'package:plantpulse/app/app.dart';

void main() {
  testWidgets('PlantPulse app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const PlantPulseApp());

    await tester.pump(const Duration(seconds: 2));

    expect(find.text('PlantPulse'), findsOneWidget);
  });
}
