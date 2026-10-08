import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../errors/app_exception.dart';

class SecureStorageService {
  SecureStorageService()
    : _storage = const FlutterSecureStorage(aOptions: AndroidOptions());

  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'plantpulse_access_token';
  static const String _refreshTokenKey = 'plantpulse_refresh_token';

  Future<void> saveAccessToken(String token) async {
    if (token.trim().isEmpty) {
      throw const AppException(
        message: 'Unable to save authentication information.',
        code: 'EMPTY_ACCESS_TOKEN',
      );
    }

    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> readAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    if (token.trim().isEmpty) {
      throw const AppException(
        message: 'Unable to save authentication information.',
        code: 'EMPTY_REFRESH_TOKEN',
      );
    }

    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> readRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<void> clearAuthentication() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
