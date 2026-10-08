import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../errors/app_exception.dart';

class LocalStorageService {
  LocalStorageService(this._preferences);

  final SharedPreferences _preferences;

  Future<void> saveString(String key, String value) async {
    try {
      final success = await _preferences.setString(key, value);

      if (!success) {
        throw const AppException(
          message: 'Unable to save local data.',
          code: 'LOCAL_STORAGE_WRITE_FAILED',
        );
      }
    } catch (error) {
      if (error is AppException) {
        rethrow;
      }

      throw const AppException(
        message: 'Unable to save local data.',
        code: 'LOCAL_STORAGE_WRITE_FAILED',
      );
    }
  }

  String? readString(String key) {
    try {
      return _preferences.getString(key);
    } catch (_) {
      throw const AppException(
        message: 'Unable to read local data.',
        code: 'LOCAL_STORAGE_READ_FAILED',
      );
    }
  }

  Future<void> saveJson(String key, Map<String, dynamic> value) async {
    await saveString(key, jsonEncode(value));
  }

  Map<String, dynamic>? readJson(String key) {
    final value = readString(key);

    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(value);

      if (decoded is! Map<String, dynamic>) {
        throw const AppException(
          message: 'Stored data has an invalid format.',
          code: 'INVALID_LOCAL_DATA',
        );
      }

      return decoded;
    } catch (error) {
      if (error is AppException) {
        rethrow;
      }

      throw const AppException(
        message: 'Stored data could not be read.',
        code: 'LOCAL_DATA_DECODE_FAILED',
      );
    }
  }

  Future<void> remove(String key) async {
    try {
      final success = await _preferences.remove(key);

      if (!success) {
        throw const AppException(
          message: 'Unable to remove local data.',
          code: 'LOCAL_STORAGE_DELETE_FAILED',
        );
      }
    } catch (error) {
      if (error is AppException) {
        rethrow;
      }

      throw const AppException(
        message: 'Unable to remove local data.',
        code: 'LOCAL_STORAGE_DELETE_FAILED',
      );
    }
  }

  Future<void> clear() async {
    try {
      final success = await _preferences.clear();

      if (!success) {
        throw const AppException(
          message: 'Unable to clear local data.',
          code: 'LOCAL_STORAGE_CLEAR_FAILED',
        );
      }
    } catch (error) {
      if (error is AppException) {
        rethrow;
      }

      throw const AppException(
        message: 'Unable to clear local data.',
        code: 'LOCAL_STORAGE_CLEAR_FAILED',
      );
    }
  }
}
