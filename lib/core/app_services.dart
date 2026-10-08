import 'package:shared_preferences/shared_preferences.dart';

import 'security/secure_storage_service.dart';
import 'security/security_service.dart';
import 'storage/app_preferences_repository.dart';
import 'storage/local_storage_service.dart';

class AppServices {
  AppServices._({
    required this.secureStorage,
    required this.localStorage,
    required this.preferences,
    required this.security,
  });

  final SecureStorageService secureStorage;
  final LocalStorageService localStorage;
  final AppPreferencesRepository preferences;
  final SecurityService security;

  static Future<AppServices> create() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final secureStorage = SecureStorageService();
    final localStorage = LocalStorageService(sharedPreferences);
    final preferences = AppPreferencesRepository(localStorage);
    final security = SecurityService(secureStorage: secureStorage);

    return AppServices._(
      secureStorage: secureStorage,
      localStorage: localStorage,
      preferences: preferences,
      security: security,
    );
  }
}
