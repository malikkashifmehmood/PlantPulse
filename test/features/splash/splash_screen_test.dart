import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantpulse/features/home/home_screen.dart';
import 'package:plantpulse/features/onboarding/onboarding_screen.dart';
import 'package:plantpulse/features/splash/splash_screen.dart';
import 'package:plantpulse/l10n/app_localizations.dart';

void main() {
  group('SplashScreen authentication routing', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    Future<void> pumpSplash(
      WidgetTester tester, {
      required MockFirebaseAuth auth,
    }) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SplashScreen(auth: auth),
        ),
      );
    }

    testWidgets('sends a signed-in user directly to Home', (tester) async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'returning-test-user',
          email: 'returning@example.com',
        ),
        signedIn: true,
      );

      await pumpSplash(tester, auth: auth);

      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1400));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });

    testWidgets('sends a signed-out user to Onboarding', (tester) async {
      final auth = MockFirebaseAuth(signedIn: false);

      await pumpSplash(tester, auth: auth);

      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1400));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });
  });
}
