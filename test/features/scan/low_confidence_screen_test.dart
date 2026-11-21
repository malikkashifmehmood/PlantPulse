import 'dart:io';

import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plantpulse/app/app.dart';
import 'package:plantpulse/core/app_services.dart';
import 'package:plantpulse/core/models/plant.dart';
import 'package:plantpulse/core/network/plantpulse_api.dart';
import 'package:plantpulse/features/scan/low_confidence_screen.dart';
import 'package:plantpulse/l10n/app_localizations.dart';

void main() {
  late AppServices services;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    services = await AppServices.create();
  });

  testWidgets(
    'automatically saves a low-confidence prediction to the selected plant',
    (tester) async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'low-confidence-user',
          email: 'grower@example.com',
          isAnonymous: false,
        ),
        signedIn: true,
      );

      final plant = Plant(
        id: 'plant-1',
        name: 'Tomato Plant',
        species: 'Tomato',
        createdAt: DateTime(2026, 11, 14),
      );

      const prediction = PlantPulsePrediction(
        predictedClass: 'Tomato___Early_blight',
        confidence: 0.36,
        probabilities: {},
        model: 'MobileNetV3Small-finetuned',
        notice: 'AI prediction only.',
      );

      await tester.pumpWidget(
        AppServicesScope(
          services: services,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: LowConfidenceScreen(
              imageFile: File('test_image.jpg'),
              prediction: prediction,
              plant: plant,
              auth: auth,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      final diagnoses = services.diagnoses.loadDiagnoses('low-confidence-user');

      expect(diagnoses, hasLength(1));
      expect(diagnoses.single.plantId, 'plant-1');
      expect(diagnoses.single.plantName, 'Tomato Plant');
      expect(diagnoses.single.result, 'Early Blight');
      expect(diagnoses.single.confidence, 0.36);

      expect(find.text('36%'), findsOneWidget);
      expect(
        find.text('Low-confidence result saved to this plant\'s history'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'does not save a low-confidence prediction when no plant is selected',
    (tester) async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'unassigned-user', isAnonymous: false),
        signedIn: true,
      );

      const prediction = PlantPulsePrediction(
        predictedClass: 'Tomato___Early_blight',
        confidence: 0.36,
        probabilities: {},
        model: 'MobileNetV3Small-finetuned',
        notice: 'AI prediction only.',
      );

      await tester.pumpWidget(
        AppServicesScope(
          services: services,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: LowConfidenceScreen(
              imageFile: File('test_image.jpg'),
              prediction: prediction,
              auth: auth,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final diagnoses = services.diagnoses.loadDiagnoses('unassigned-user');

      expect(diagnoses, isEmpty);
      expect(find.text('36%'), findsOneWidget);
      expect(find.text('Save prediction'), findsNothing);
    },
  );
}
