import 'dart:convert';

import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../models/treatment_progress.dart';

class TreatmentProgressRepository {
  TreatmentProgressRepository(this._storage);

  final LocalStorageService _storage;

  String _keyFor({required String scope, required String contextId}) {
    final normalizedScope = scope.trim();
    final normalizedContext = contextId.trim();

    if (normalizedScope.isEmpty) {
      throw ArgumentError.value(scope, 'scope', 'Must not be empty.');
    }

    if (normalizedContext.isEmpty) {
      throw ArgumentError.value(contextId, 'contextId', 'Must not be empty.');
    }

    return '${StorageKeys.cachedTreatmentPlans}_'
        '${Uri.encodeComponent(normalizedScope)}_'
        '${Uri.encodeComponent(normalizedContext)}';
  }

  TreatmentProgress? loadProgress({
    required String scope,
    required String contextId,
  }) {
    final json = _storage.readString(
      _keyFor(scope: scope, contextId: contextId),
    );

    if (json == null || json.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(json);

      if (decoded is! Map) {
        throw const FormatException(
          'Stored treatment progress must be an object.',
        );
      }

      return TreatmentProgress.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      throw const FormatException(
        'Saved treatment progress is invalid or cannot be decoded.',
      );
    }
  }

  Future<void> saveProgress({
    required String scope,
    required String contextId,
    required TreatmentProgress progress,
  }) {
    return _storage.saveString(
      _keyFor(scope: scope, contextId: contextId),
      jsonEncode(progress.toJson()),
    );
  }

  Future<void> deleteProgress({
    required String scope,
    required String contextId,
  }) {
    return _storage.remove(_keyFor(scope: scope, contextId: contextId));
  }
}
