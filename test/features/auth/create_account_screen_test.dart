import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:plantpulse/features/auth/create_account_screen.dart';
import 'package:plantpulse/features/home/home_screen.dart';
import 'package:plantpulse/l10n/app_localizations.dart';

void main() {
  late MockFirebaseAuth mockAuth;

  Future<void> openCreateAccountScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CreateAccountScreen(auth: mockAuth),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder fieldAt(int index) => find.byType(TextFormField).at(index);

  Future<void> enterValidDetails(WidgetTester tester) async {
    await tester.enterText(fieldAt(0), 'Ali Khan');
    await tester.enterText(fieldAt(1), 'ali@example.com');
    await tester.enterText(fieldAt(2), 'PlantPulse123');
    await tester.enterText(fieldAt(3), 'PlantPulse123');
  }

  Future<void> tapCreateAccount(WidgetTester tester) async {
    final button = find.widgetWithText(FilledButton, 'Create Account');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
  }

  setUp(() {
    mockAuth = MockFirebaseAuth();
  });

  group('CreateAccountScreen', () {
    testWidgets('displays the registration form', (tester) async {
      await openCreateAccountScreen(tester);

      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('Full name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm password'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
      expect(find.text('Already have an account? Sign in'), findsOneWidget);
    });

    testWidgets('shows validation errors for empty fields', (tester) async {
      await openCreateAccountScreen(tester);
      await tapCreateAccount(tester);

      expect(find.text('Full name is required.'), findsOneWidget);
      expect(find.text('Email is required.'), findsOneWidget);
      expect(find.text('Password is required.'), findsOneWidget);
      expect(find.text('Please confirm your password.'), findsOneWidget);
    });

    testWidgets('rejects an invalid email address', (tester) async {
      await openCreateAccountScreen(tester);
      await enterValidDetails(tester);
      await tester.enterText(fieldAt(1), 'invalid-email');
      await tapCreateAccount(tester);

      expect(find.text('Enter a valid email address.'), findsOneWidget);
    });

    testWidgets('rejects a password shorter than eight characters', (
      tester,
    ) async {
      await openCreateAccountScreen(tester);
      await enterValidDetails(tester);
      await tester.enterText(fieldAt(2), 'short');
      await tester.enterText(fieldAt(3), 'short');
      await tapCreateAccount(tester);

      expect(
        find.text('Password must contain at least 8 characters.'),
        findsOneWidget,
      );
    });

    testWidgets('rejects passwords that do not match', (tester) async {
      await openCreateAccountScreen(tester);
      await enterValidDetails(tester);
      await tester.enterText(fieldAt(3), 'Different123');
      await tapCreateAccount(tester);

      expect(find.text('Passwords do not match.'), findsOneWidget);
    });

    testWidgets('toggles password visibility independently', (tester) async {
      await openCreateAccountScreen(tester);

      final passwordFields = find.byType(EditableText);
      expect(passwordFields, findsNWidgets(4));

      expect(
        tester.widget<EditableText>(passwordFields.at(2)).obscureText,
        isTrue,
      );
      expect(
        tester.widget<EditableText>(passwordFields.at(3)).obscureText,
        isTrue,
      );

      // Reveal the first password field.
      final firstVisibilityButton = find.byTooltip('Show password').first;

      await tester.ensureVisible(firstVisibilityButton);
      await tester.tap(firstVisibilityButton);
      await tester.pumpAndSettle();

      expect(
        tester.widget<EditableText>(passwordFields.at(2)).obscureText,
        isFalse,
      );
      expect(
        tester.widget<EditableText>(passwordFields.at(3)).obscureText,
        isTrue,
      );

      // Reveal the confirmation field independently.
      final confirmVisibilityButton = find.byTooltip('Show password');

      await tester.ensureVisible(confirmVisibilityButton);
      await tester.tap(confirmVisibilityButton);
      await tester.pumpAndSettle();

      expect(
        tester.widget<EditableText>(passwordFields.at(3)).obscureText,
        isFalse,
      );
    });

    testWidgets('creates a mock account and opens the home screen', (
      tester,
    ) async {
      await openCreateAccountScreen(tester);
      await enterValidDetails(tester);
      await tapCreateAccount(tester);
      await tester.pumpAndSettle();

      final user = mockAuth.currentUser;

      expect(user, isNotNull);
      expect(user!.email, 'ali@example.com');
      expect(user.displayName, 'Ali Khan');
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Create account'), findsNothing);
    });

    testWidgets('signs out the existing user before entering Guest mode', (
      tester,
    ) async {
      final existingUser = MockUser(
        uid: 'previous-account',
        email: 'previous@example.com',
      );
      mockAuth = MockFirebaseAuth(mockUser: existingUser, signedIn: true);

      await openCreateAccountScreen(tester);

      expect(mockAuth.currentUser?.uid, 'previous-account');

      final guestButton = find.text('Continue as Guest');
      await tester.ensureVisible(guestButton);
      await tester.tap(guestButton);
      await tester.pumpAndSettle();

      expect(mockAuth.currentUser, isNull);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('does not enter Guest mode when sign-out fails', (
      tester,
    ) async {
      final existingUser = MockUser(
        uid: 'previous-account',
        email: 'previous@example.com',
      );
      mockAuth = MockFirebaseAuth(mockUser: existingUser, signedIn: true);

      whenCalling(
        Invocation.method(#signOut, null),
      ).on(mockAuth).thenThrow(Exception('Simulated sign-out failure'));

      await openCreateAccountScreen(tester);

      final guestButton = find.text('Continue as Guest');
      await tester.ensureVisible(guestButton);
      await tester.tap(guestButton);
      await tester.pumpAndSettle();

      expect(mockAuth.currentUser?.uid, 'previous-account');
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
    });
  });
}
