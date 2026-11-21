import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plantpulse/app/app.dart';
import 'package:plantpulse/core/app_services.dart';
import 'package:plantpulse/core/network/plantpulse_api.dart';
import 'package:plantpulse/features/treatment/treatment_screen.dart';
import 'package:plantpulse/l10n/app_localizations.dart';

void main() {
  late AppServices services;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    services = await AppServices.create();
  });

  Future<void> openTreatment(
    WidgetTester tester, {
    PlantPulsePrediction? prediction,
    String? plantName,
    String? species,
    String? plantId,
    String? userScope,
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(
      AppServicesScope(
        services: services,
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TreatmentScreen(
            prediction: prediction,
            plantName: plantName,
            species: species,
            plantId: plantId,
            userScope: userScope,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  PlantPulsePrediction createPrediction(String predictedClass) {
    return PlantPulsePrediction(
      predictedClass: predictedClass,
      confidence: 0.92,
      probabilities: {predictedClass: 0.92},
      model: 'MobileNetV3Small-finetuned',
      notice: 'Test prediction',
    );
  }

  group('TreatmentScreen', () {
    testWidgets('displays the general care plan without a prediction', (
      tester,
    ) async {
      await openTreatment(tester);

      final l10n = AppLocalizations.of(
        tester.element(find.byType(TreatmentScreen)),
      );

      expect(find.text(l10n.treatmentTitle), findsOneWidget);
      expect(find.text(l10n.treatmentGeneralTitle), findsOneWidget);
      expect(find.text(l10n.treatmentGeneralDescription), findsOneWidget);
      expect(find.text(l10n.treatmentGeneralNotice), findsOneWidget);

      expect(find.text(l10n.treatmentGeneralStep1), findsOneWidget);
      expect(find.text(l10n.treatmentGeneralStep2), findsOneWidget);
      expect(find.text(l10n.treatmentGeneralStep3), findsOneWidget);
      expect(find.text(l10n.treatmentGeneralStep4), findsOneWidget);
    });

    testWidgets('displays the correct plan for early blight', (tester) async {
      await openTreatment(
        tester,
        prediction: createPrediction('Tomato___Early_blight'),
        plantName: 'My Tomato',
        species: 'Tomato',
        plantId: 'early-blight-plant',
      );

      final l10n = AppLocalizations.of(
        tester.element(find.byType(TreatmentScreen)),
      );

      expect(find.text(l10n.treatmentEarlyBlightTitle), findsOneWidget);
      expect(find.text(l10n.treatmentEarlyBlightDescription), findsOneWidget);

      expect(find.text('My Tomato'), findsOneWidget);
      expect(find.text('Tomato'), findsOneWidget);

      expect(find.text(l10n.treatmentEarlyBlightStep1), findsOneWidget);
      expect(find.text(l10n.treatmentEarlyBlightStep2), findsOneWidget);
      expect(find.text(l10n.treatmentEarlyBlightStep3), findsOneWidget);
      expect(find.text(l10n.treatmentEarlyBlightStep4), findsOneWidget);

      expect(find.text(l10n.treatmentGeneralNotice), findsNothing);
    });

    testWidgets('updates progress when a treatment step is completed', (
      tester,
    ) async {
      await openTreatment(tester);

      final l10n = AppLocalizations.of(
        tester.element(find.byType(TreatmentScreen)),
      );

      expect(find.text(l10n.treatmentStepsCompleted(0, 4)), findsOneWidget);

      final firstStep = find.text(l10n.treatmentGeneralStep1);

      await tester.ensureVisible(firstStep);
      await tester.tap(firstStep);
      await tester.pumpAndSettle();

      expect(find.text(l10n.treatmentStepsCompleted(1, 4)), findsOneWidget);
    });

    testWidgets('displays Urdu translations when Urdu locale is selected', (
      tester,
    ) async {
      await openTreatment(tester, locale: const Locale('ur'));

      final l10n = AppLocalizations.of(
        tester.element(find.byType(TreatmentScreen)),
      );

      expect(find.text(l10n.treatmentTitle), findsOneWidget);
      expect(find.text(l10n.treatmentGeneralTitle), findsOneWidget);
      expect(find.text(l10n.treatmentSafetyNotice), findsOneWidget);
      expect(find.text(l10n.treatmentStartPlan), findsOneWidget);
    });

    testWidgets('displays the healthy plant care plan', (tester) async {
      await openTreatment(
        tester,
        prediction: createPrediction('Tomato___healthy'),
      );

      final l10n = AppLocalizations.of(
        tester.element(find.byType(TreatmentScreen)),
      );

      expect(find.text(l10n.treatmentHealthyTitle), findsOneWidget);
      expect(find.text(l10n.treatmentHealthyDescription), findsOneWidget);

      expect(find.text(l10n.treatmentHealthyStep1), findsOneWidget);
      expect(find.text(l10n.treatmentHealthyStep2), findsOneWidget);
      expect(find.text(l10n.treatmentHealthyStep3), findsOneWidget);
      expect(find.text(l10n.treatmentHealthyStep4), findsOneWidget);

      expect(find.text(l10n.treatmentGeneralNotice), findsNothing);
    });

    testWidgets('shows a general care plan for an unsupported prediction', (
      tester,
    ) async {
      await openTreatment(
        tester,
        prediction: createPrediction('Unsupported_Tomato_Class'),
      );

      final l10n = AppLocalizations.of(
        tester.element(find.byType(TreatmentScreen)),
      );

      expect(find.text('Unsupported_Tomato_Class'), findsOneWidget);
      expect(find.text(l10n.treatmentUnsupportedDescription), findsOneWidget);
      expect(find.text(l10n.treatmentGeneralNotice), findsOneWidget);
      expect(find.text(l10n.treatmentGeneralStep1), findsOneWidget);
    });
  });
}
