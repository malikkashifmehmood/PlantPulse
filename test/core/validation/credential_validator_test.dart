import 'package:flutter_test/flutter_test.dart';
import 'package:plantpulse/core/security/security_constants.dart';
import 'package:plantpulse/core/validation/credential_validator.dart';

void main() {
  group('CredentialValidator email', () {
    test('accepts a valid email', () {
      expect(CredentialValidator.validateEmail('user@example.com'), isNull);
    });

    test('accepts an email with surrounding whitespace', () {
      expect(CredentialValidator.validateEmail('  user@example.com  '), isNull);
    });

    test('rejects an empty email', () {
      expect(CredentialValidator.validateEmail(''), 'Email is required.');
    });

    test('rejects a whitespace-only email', () {
      expect(CredentialValidator.validateEmail('   '), 'Email is required.');
    });

    test('rejects an invalid email', () {
      expect(
        CredentialValidator.validateEmail('invalid-email'),
        'Enter a valid email address.',
      );
    });

    test('rejects an email exceeding the maximum length', () {
      final email = '${'a' * SecurityConstants.maxTextInputLength}@x.com';

      expect(CredentialValidator.validateEmail(email), 'Email is too long.');
    });
  });

  group('CredentialValidator password', () {
    test('accepts a password with the minimum length', () {
      expect(CredentialValidator.validatePassword('12345678'), isNull);
    });

    test('rejects a short password', () {
      expect(
        CredentialValidator.validatePassword('1234567'),
        'Password must contain at least 8 characters.',
      );
    });

    test('rejects an empty password', () {
      expect(CredentialValidator.validatePassword(''), 'Password is required.');
    });

    test('rejects a password exceeding the maximum length', () {
      final password = 'a' * (SecurityConstants.maxTextInputLength + 1);

      expect(
        CredentialValidator.validatePassword(password),
        'Password is too long.',
      );
    });

    test('accepts a password at the maximum length', () {
      final password = 'a' * SecurityConstants.maxTextInputLength;

      expect(CredentialValidator.validatePassword(password), isNull);
    });
  });
}
