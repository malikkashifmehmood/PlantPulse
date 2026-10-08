import 'secure_storage_service.dart';
import 'session_service.dart';

class SecurityService {
  SecurityService({required SecureStorageService secureStorage})
    : session = SessionService(secureStorage);

  final SessionService session;

  void recordUserActivity() {
    session.markActivity();
  }

  Future<bool> isAuthenticated() {
    return session.hasAuthenticatedSession();
  }

  Future<void> signOut() {
    return session.logout();
  }
}
