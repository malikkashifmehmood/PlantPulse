import 'package:flutter_test/flutter_test.dart';
import 'package:plantpulse/core/security/login_attempt_guard.dart';
import 'package:plantpulse/core/security/security_constants.dart';

void main() {
  group('LoginAttemptGuard', () {
    test('starts unlocked with zero failed attempts', () {
      final guard = LoginAttemptGuard();

      expect(guard.failedAttempts, 0);
      expect(guard.isLocked, isFalse);
      expect(guard.remainingLockout, isNull);
    });

    test('locks after the maximum number of failed attempts', () {
      final guard = LoginAttemptGuard();

      for (var i = 0; i < SecurityConstants.maxLoginAttempts; i++) {
        guard.recordFailedAttempt();
      }

      expect(guard.failedAttempts, SecurityConstants.maxLoginAttempts);
      expect(guard.isLocked, isTrue);
      expect(guard.remainingLockout, isNotNull);
    });

    test('does not lock before reaching the attempt limit', () {
      final guard = LoginAttemptGuard();

      for (var i = 0; i < SecurityConstants.maxLoginAttempts - 1; i++) {
        guard.recordFailedAttempt();
      }

      expect(guard.failedAttempts, SecurityConstants.maxLoginAttempts - 1);
      expect(guard.isLocked, isFalse);
    });

    test('does not increase attempts while locked', () {
      final guard = LoginAttemptGuard();

      for (var i = 0; i < SecurityConstants.maxLoginAttempts; i++) {
        guard.recordFailedAttempt();
      }

      guard.recordFailedAttempt();

      expect(guard.failedAttempts, SecurityConstants.maxLoginAttempts);
      expect(guard.isLocked, isTrue);
    });

    test('successful login resets failed attempts and lockout', () {
      final guard = LoginAttemptGuard();

      guard.recordFailedAttempt();
      guard.recordFailedAttempt();
      guard.recordSuccessfulLogin();

      expect(guard.failedAttempts, 0);
      expect(guard.isLocked, isFalse);
      expect(guard.remainingLockout, isNull);
    });

    test('reset clears failed attempts and lockout', () {
      final guard = LoginAttemptGuard();

      for (var i = 0; i < SecurityConstants.maxLoginAttempts; i++) {
        guard.recordFailedAttempt();
      }

      guard.reset();

      expect(guard.failedAttempts, 0);
      expect(guard.isLocked, isFalse);
      expect(guard.remainingLockout, isNull);
    });

    test('remaining lockout is positive while locked', () {
      final guard = LoginAttemptGuard();

      for (var i = 0; i < SecurityConstants.maxLoginAttempts; i++) {
        guard.recordFailedAttempt();
      }

      final remaining = guard.remainingLockout;

      expect(remaining, isNotNull);
      expect(remaining!.inSeconds, greaterThan(0));
      expect(
        remaining,
        lessThanOrEqualTo(SecurityConstants.loginLockoutDuration),
      );
    });
  });
}
