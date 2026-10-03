import 'package:flutter_test/flutter_test.dart';
import 'package:plantpulse/app/app.dart';

void main() {
  testWidgets('PlantPulse app starts', (tester) async {
    await tester.pumpWidget(const PlantPulseApp());
    expect(find.text('PlantPulse'), findsOneWidget);
  });
}
