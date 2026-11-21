import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plantpulse/app/app.dart';
import 'package:plantpulse/core/app_services.dart';
import 'package:plantpulse/core/models/plant_diagnosis.dart';
import 'package:plantpulse/features/alerts/alerts_screen.dart';
import 'package:plantpulse/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppServices services;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    services = await AppServices.create();
  });

  PlantDiagnosis createDiagnosis({
    String id = 'diagnosis-1',
    String plantName = 'Tomato Roma',
    String result = 'Early Blight',
    double confidence = 0.92,
    DateTime? createdAt,
  }) {
    return PlantDiagnosis(
      id: id,
      plantId: 'plant-1',
      plantName: plantName,
      species: 'Tomato',
      result: result,
      confidence: confidence,
      symptoms: const ['Brown spots'],
      createdAt: createdAt ?? DateTime.utc(2026, 11, 14),
    );
  }

  Future<void> openAlerts(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(
      AppServicesScope(
        services: services,
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AlertsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  group('AlertsScreen', () {
    testWidgets('displays the localized empty state', (tester) async {
      await openAlerts(tester);

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      expect(find.text(l10n.alertsTitle), findsWidgets);
      expect(find.text(l10n.alertsNoUpdates), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('displays saved unhealthy diagnoses', (tester) async {
      await services.diagnoses.saveDiagnosis(
        'guest',
        createDiagnosis(plantName: 'Tomato Roma', result: 'Early Blight'),
      );

      await openAlerts(tester);

      expect(find.text('Tomato Roma'), findsWidgets);
      expect(find.text('Early Blight'), findsWidgets);
      expect(find.text('92%'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'renders long diagnosis details on a narrow Urdu screen without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(320, 1400);
        tester.view.devicePixelRatio = 1;

        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        const longPlantName =
            'Tomato Roma Heritage Garden Plant With A Very Long Name';
        const longResult =
            'Tomato Yellow Leaf Curl Virus With Additional Diagnostic Details';

        await services.diagnoses.saveDiagnosis(
          'guest',
          createDiagnosis(
            plantName: longPlantName,
            result: longResult,
            confidence: 0.87,
          ),
        );

        await openAlerts(tester, locale: const Locale('ur'));

        final alertsList = find.byType(ListView);

        // Scroll the Alerts list until the lazy list item is built.
        for (var i = 0; i < 20; i++) {
          if (find.text(longPlantName).evaluate().isNotEmpty) {
            break;
          }

          await tester.drag(alertsList, const Offset(0, -600));
          await tester.pumpAndSettle();
        }

        expect(find.text(longPlantName), findsWidgets);
        expect(find.text(longResult), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
