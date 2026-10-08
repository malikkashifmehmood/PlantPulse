import 'package:flutter_test/flutter_test.dart';

import 'package:plantpulse/core/security/login_attempt_guard.dart';

void main() {
  test('locks after the maximum number of failed attempts', () {
    final guard = LoginAttemptGuard();

    expect(guard.isLocked, isFalse);

    for (var i = 0; i < 5; i++) {
      guard.recordFailedAttempt();
    }

    expect(guard.failedAttempts, 5);
    expect(guard.isLocked, isTrue);
  });

  test('successful login resets failed attempts', () {
    final guard = LoginAttemptGuard();

    guard.recordFailedAttempt();
    guard.recordFailedAttempt();

    expect(guard.failedAttempts, 2);

    guard.recordSuccessfulLogin();

    expect(guard.failedAttempts, 0);
    expect(guard.isLocked, isFalse);
  });

  test('failed attempts do not increase while locked', () {
    final guard = LoginAttemptGuard();

    for (var i = 0; i < 5; i++) {
      guard.recordFailedAttempt();
    }

    guard.recordFailedAttempt();

    expect(guard.failedAttempts, 5);
    expect(guard.isLocked, isTrue);
  });
}
