import 'local_storage_service.dart';
import 'storage_keys.dart';

class AppPreferencesRepository {
  AppPreferencesRepository(this._storage);

  final LocalStorageService _storage;

  Future<void> setOnboardingCompleted(bool completed) async {
    await _storage.saveString(
      StorageKeys.onboardingCompleted,
      completed.toString(),
    );
  }

  bool isOnboardingCompleted() {
    final value = _storage.readString(StorageKeys.onboardingCompleted);

    return value == 'true';
  }

  Future<void> setSelectedLanguage(String language) async {
    await _storage.saveString(StorageKeys.selectedLanguage, language);
  }

  String? getSelectedLanguage() {
    return _storage.readString(StorageKeys.selectedLanguage);
  }

  Future<void> setAppTheme(String theme) async {
    await _storage.saveString(StorageKeys.appTheme, theme);
  }

  String? getAppTheme() {
    return _storage.readString(StorageKeys.appTheme);
  }
}
