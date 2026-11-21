import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:plantpulse/features/auth/auth_screen.dart';
import 'package:plantpulse/features/home/home_screen.dart';
import 'package:plantpulse/l10n/app_localizations.dart';

void main() {
  group('AuthScreen widget tests', () {
    Future<MockFirebaseAuth> openAuthScreen(
      WidgetTester tester, {
      List<MockUser> users = const [],
    }) async {
      final auth = MockFirebaseAuth(
        mockUser: users.isEmpty ? null : users.first,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AuthScreen(auth: auth),
        ),
      );

      return auth;
    }

    testWidgets('displays the login form', (tester) async {
      await openAuthScreen(tester);

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
    });

    testWidgets('shows validation errors for empty fields', (tester) async {
      await openAuthScreen(tester);

      await tester.ensureVisible(find.text('Sign In'));
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required.'), findsOneWidget);
      expect(find.text('Password is required.'), findsOneWidget);
    });

    testWidgets('rejects an invalid email address', (tester) async {
      await openAuthScreen(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
      await tester.enterText(find.byType(TextFormField).at(1), 'validpass123');

      await tester.ensureVisible(find.text('Sign In'));
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (tester) async {
      await openAuthScreen(tester);

      EditableText passwordEditor() {
        return tester.widget<EditableText>(
          find.descendant(
            of: find.byType(TextFormField).at(1),
            matching: find.byType(EditableText),
          ),
        );
      }

      expect(passwordEditor().obscureText, isTrue);

      await tester.tap(find.byTooltip('Show password'));
      await tester.pumpAndSettle();

      expect(passwordEditor().obscureText, isFalse);
      expect(find.byTooltip('Hide password'), findsOneWidget);
    });

    testWidgets('signs in with a registered mock user', (tester) async {
      final mockUser = MockUser(
        isAnonymous: false,
        uid: 'test-user',
        email: 'user@example.com',
      );
      final auth = MockFirebaseAuth(mockUser: mockUser, signedIn: false);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AuthScreen(auth: auth),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'validpass123');

      await tester.ensureVisible(find.text('Sign In'));
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(auth.currentUser, isNotNull);
    });

    testWidgets('signs out the existing user before entering Guest mode', (
      tester,
    ) async {
      final existingUser = MockUser(
        uid: 'previous-account',
        email: 'previous@example.com',
      );
      final auth = MockFirebaseAuth(mockUser: existingUser, signedIn: true);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AuthScreen(auth: auth),
        ),
      );

      expect(auth.currentUser?.uid, 'previous-account');

      await tester.ensureVisible(find.text('Continue as Guest'));
      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      expect(auth.currentUser, isNull);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('does not enter Guest mode when sign-out fails', (
      tester,
    ) async {
      final existingUser = MockUser(
        uid: 'previous-account',
        email: 'previous@example.com',
      );
      final auth = MockFirebaseAuth(mockUser: existingUser, signedIn: true);

      whenCalling(
        Invocation.method(#signOut, null),
      ).on(auth).thenThrow(Exception('Simulated sign-out failure'));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AuthScreen(auth: auth),
        ),
      );

      await tester.ensureVisible(find.text('Continue as Guest'));
      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      expect(auth.currentUser?.uid, 'previous-account');
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
    });
  });
}
