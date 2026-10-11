import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantpulse/features/auth/create_account_screen.dart';
import 'package:plantpulse/features/home/home_screen.dart';

void main() {
  late MockFirebaseAuth mockAuth;

  Future<void> openCreateAccountScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(
      MaterialApp(home: CreateAccountScreen(auth: mockAuth)),
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

      await tester.tap(find.byTooltip('Show password').first);
      await tester.pumpAndSettle();

      expect(
        tester.widget<EditableText>(passwordFields.at(2)).obscureText,
        isFalse,
      );
      expect(
        tester.widget<EditableText>(passwordFields.at(3)).obscureText,
        isTrue,
      );

      await tester.tap(find.byTooltip('Show password'));
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
  });
}
