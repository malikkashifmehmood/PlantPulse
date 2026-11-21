import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plantpulse/app/app.dart';
import 'package:plantpulse/core/app_services.dart';
import 'package:plantpulse/features/expert/expert_screen.dart';
import 'package:plantpulse/features/expert/models/plant_assistant_message.dart';
import 'package:plantpulse/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppServices services;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    services = await AppServices.create();
  });

  Future<void> openExpert(
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
          home: const ExpertScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  group('ExpertScreen', () {
    testWidgets('sends a message and persists the conversation', (
      tester,
    ) async {
      await openExpert(tester);

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.tap(find.byTooltip(l10n.expertSendMessage));
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final savedMessages = services.plantAssistantRepository.loadMessages(
        'guest',
      );

      expect(savedMessages, isNotEmpty);
      expect(
        savedMessages.any(
          (message) => message.isUser && message.text == 'Hello',
        ),
        isTrue,
      );
      expect(savedMessages.any((message) => !message.isUser), isTrue);
    });

    testWidgets('restores the saved conversation after reopening', (
      tester,
    ) async {
      await services.plantAssistantRepository.appendMessage(
        'guest',
        PlantAssistantMessage(
          id: 'saved-user-message',
          text: 'How often should I water my tomato plant?',
          isUser: true,
          createdAt: DateTime.utc(2026, 11, 17),
        ),
      );

      await openExpert(tester);

      expect(
        find.text('How often should I water my tomato plant?'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('clears conversation after confirmation', (tester) async {
      await services.plantAssistantRepository.appendMessage(
        'guest',
        PlantAssistantMessage(
          id: 'message-to-clear',
          text: 'Please help with my tomato plant.',
          isUser: true,
          createdAt: DateTime.utc(2026, 11, 17),
        ),
      );

      await openExpert(tester);

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      await tester.tap(find.byTooltip(l10n.expertClearConversation));
      await tester.pumpAndSettle();

      expect(find.text(l10n.expertCancel), findsOneWidget);
      expect(find.text(l10n.expertClear), findsOneWidget);

      await tester.tap(find.text(l10n.expertClear));
      await tester.pumpAndSettle();

      expect(services.plantAssistantRepository.loadMessages('guest'), isEmpty);
      expect(find.text('Please help with my tomato plant.'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'renders long messages on a narrow Urdu screen without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(320, 1400);
        tester.view.devicePixelRatio = 1;

        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        const longMessage =
            'My tomato plant has developed many unusual brown spots '
            'on several leaves and I would like detailed guidance '
            'about possible causes and appropriate treatment steps.';

        await services.plantAssistantRepository.appendMessage(
          'guest',
          PlantAssistantMessage(
            id: 'long-urdu-screen-message',
            text: longMessage,
            isUser: true,
            createdAt: DateTime.utc(2026, 11, 17),
          ),
        );

        await openExpert(tester, locale: const Locale('ur'));

        expect(find.text(longMessage), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
