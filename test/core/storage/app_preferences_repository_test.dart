import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plantpulse/core/storage/app_preferences_repository.dart';
import 'package:plantpulse/core/storage/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppPreferencesRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    final preferences = await SharedPreferences.getInstance();
    final storage = LocalStorageService(preferences);

    repository = AppPreferencesRepository(storage);
  });

  group('Selected language', () {
    test('returns null when no language has been saved', () {
      expect(repository.getSelectedLanguage(), isNull);
    });

    test('saves and retrieves English', () async {
      await repository.setSelectedLanguage('en');

      expect(repository.getSelectedLanguage(), 'en');
    });

    test('saves and retrieves Urdu', () async {
      await repository.setSelectedLanguage('ur');

      expect(repository.getSelectedLanguage(), 'ur');
    });

    test('updates the previously saved language', () async {
      await repository.setSelectedLanguage('en');
      await repository.setSelectedLanguage('ur');

      expect(repository.getSelectedLanguage(), 'ur');
    });
  });
}
