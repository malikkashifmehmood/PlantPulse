import '../errors/app_exception.dart';
import 'secure_storage_service.dart';
import 'security_constants.dart';

class SessionService {
  SessionService(this._secureStorage);

  final SecureStorageService _secureStorage;

  DateTime? _lastActivity;

  void markActivity() {
    _lastActivity = DateTime.now();
  }

  bool get isSessionActive {
    final lastActivity = _lastActivity;

    if (lastActivity == null) {
      return false;
    }

    return DateTime.now().difference(lastActivity) <
        SecurityConstants.sessionTimeout;
  }

  Future<bool> hasAuthenticatedSession() async {
    try {
      final token = await _secureStorage.readAccessToken();

      if (token == null || token.trim().isEmpty) {
        return false;
      }

      return isSessionActive;
    } catch (_) {
      throw const AppException(
        message: 'Unable to verify the current session.',
        code: 'SESSION_CHECK_FAILED',
      );
    }
  }

  Future<void> logout() async {
    _lastActivity = null;

    try {
      await _secureStorage.clearAuthentication();
    } catch (_) {
      throw const AppException(
        message: 'Unable to complete sign out securely.',
        code: 'LOGOUT_FAILED',
      );
    }
  }
}
