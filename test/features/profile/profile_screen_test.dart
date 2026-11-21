import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plantpulse/app/app.dart';
import 'package:plantpulse/core/app_services.dart';
import 'package:plantpulse/features/auth/auth_screen.dart';
import 'package:plantpulse/features/profile/profile_screen.dart';
import 'package:plantpulse/l10n/app_localizations.dart';

const MethodChannel _secureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

void main() {
  late AppServices services;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, (
          MethodCall call,
        ) async {
          // Secure-storage operations complete successfully in widget tests.
          return null;
        });

    services = await AppServices.create();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, null);
  });

  Future<void> openProfile(
    WidgetTester tester, {
    required MockFirebaseAuth auth,
  }) async {
    await tester.pumpWidget(
      AppServicesScope(
        services: services,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProfileScreen(auth: auth),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  group('ProfileScreen', () {
    testWidgets('displays the registered Firebase user', (tester) async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'profile-user',
          email: 'grower@example.com',
          displayName: 'Test Grower',
          isAnonymous: false,
        ),
        signedIn: true,
      );

      await openProfile(tester, auth: auth);

      expect(find.text('Test Grower'), findsOneWidget);
      expect(find.text('grower@example.com'), findsOneWidget);
      expect(find.text('Farm User'), findsNothing);
      expect(find.text('user@example.com'), findsNothing);
    });

    testWidgets('shows guest information for anonymous users', (tester) async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'guest-user', isAnonymous: true),
        signedIn: true,
      );

      await openProfile(tester, auth: auth);

      expect(find.text('Guest'), findsOneWidget);
      expect(find.text('Guest account'), findsOneWidget);
    });

    testWidgets('displays real empty plant and scan counts', (tester) async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'empty-profile-user',
          email: 'empty@example.com',
          isAnonymous: false,
        ),
        signedIn: true,
      );

      await openProfile(tester, auth: auth);

      expect(find.text('Plants'), findsNWidgets(2));
      expect(find.text('Scans'), findsOneWidget);
      expect(find.text('0'), findsNWidgets(2));
      expect(find.text('24'), findsNothing);
      expect(find.text('86'), findsNothing);
      expect(find.text('12'), findsNothing);
    });

    testWidgets('keeps profile navigation and sign-out controls', (
      tester,
    ) async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'navigation-user',
          email: 'navigation@example.com',
          displayName: 'Navigation User',
          isAnonymous: false,
        ),
        signedIn: true,
      );

      await openProfile(tester, auth: auth);

      expect(find.text('Scan history'), findsOneWidget);
      expect(find.text('Ask an expert'), findsOneWidget);
      expect(find.text('Settings & privacy'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
    });

    testWidgets('signs out and navigates to the authentication screen', (
      tester,
    ) async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'signout-user',
          email: 'signout@example.com',
          displayName: 'Sign Out User',
          isAnonymous: false,
        ),
        signedIn: true,
      );

      await openProfile(tester, auth: auth);

      expect(auth.currentUser, isNotNull);

      await tester.ensureVisible(find.text('Sign out'));
      await tester.tap(find.text('Sign out'));

      // Allow asynchronous Firebase sign-out, secure-storage cleanup,
      // and navigation to complete without waiting for repeating animations.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(auth.currentUser, isNull);
      expect(find.byType(ProfileScreen), findsNothing);
      expect(find.byType(AuthScreen), findsOneWidget);
    });
  });
}
