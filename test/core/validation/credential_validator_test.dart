import 'package:flutter_test/flutter_test.dart';

import 'package:plantpulse/core/validation/credential_validator.dart';

void main() {
  group('CredentialValidator email', () {
    test('accepts a valid email', () {
      expect(CredentialValidator.validateEmail('user@example.com'), isNull);
    });

    test('rejects an empty email', () {
      expect(CredentialValidator.validateEmail(''), 'Email is required.');
    });

    test('rejects an invalid email', () {
      expect(
        CredentialValidator.validateEmail('invalid-email'),
        'Enter a valid email address.',
      );
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
  });
}
