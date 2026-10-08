import 'security_constants.dart';

class LoginAttemptGuard {
  int _failedAttempts = 0;
  DateTime? _lockedUntil;

  int get failedAttempts => _failedAttempts;

  bool get isLocked {
    final lockedUntil = _lockedUntil;

    if (lockedUntil == null) {
      return false;
    }

    if (DateTime.now().isBefore(lockedUntil)) {
      return true;
    }

    _lockedUntil = null;
    _failedAttempts = 0;
    return false;
  }

  Duration? get remainingLockout {
    final lockedUntil = _lockedUntil;

    if (lockedUntil == null || !isLocked) {
      return null;
    }

    return lockedUntil.difference(DateTime.now());
  }

  void recordFailedAttempt() {
    if (isLocked) {
      return;
    }

    _failedAttempts++;

    if (_failedAttempts >= SecurityConstants.maxLoginAttempts) {
      _lockedUntil = DateTime.now().add(SecurityConstants.loginLockoutDuration);
    }
  }

  void recordSuccessfulLogin() {
    _failedAttempts = 0;
    _lockedUntil = null;
  }

  void reset() {
    _failedAttempts = 0;
    _lockedUntil = null;
  }
}
