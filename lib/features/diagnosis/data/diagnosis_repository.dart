import 'dart:convert';

import '../../../core/models/plant_diagnosis.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/storage_keys.dart';

class DiagnosisRepository {
  DiagnosisRepository(this._storage);

  final LocalStorageService _storage;

  String _keyForScope(String scope) {
    final normalizedScope = scope.trim();

    if (normalizedScope.isEmpty) {
      throw ArgumentError.value(scope, 'scope', 'Must not be empty.');
    }

    return '${StorageKeys.cachedDiagnoses}_'
        '${Uri.encodeComponent(normalizedScope)}';
  }

  List<PlantDiagnosis> loadDiagnoses(String scope) {
    final json = _storage.readString(_keyForScope(scope));

    if (json == null || json.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(json);

      if (decoded is! List) {
        throw const FormatException('Stored diagnoses must be a list.');
      }

      return decoded.map<PlantDiagnosis>((item) {
          if (item is! Map) {
            throw const FormatException('Invalid diagnosis record.');
          }

          return PlantDiagnosis.fromJson(Map<String, dynamic>.from(item));
        }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      throw const FormatException(
        'Saved diagnosis data is invalid or cannot be decoded.',
      );
    }
  }

  List<PlantDiagnosis> loadForPlant(String scope, String plantId) {
    return loadDiagnoses(
      scope,
    ).where((diagnosis) => diagnosis.plantId == plantId).toList();
  }

  Future<void> saveDiagnosis(String scope, PlantDiagnosis diagnosis) async {
    final diagnoses = loadDiagnoses(scope);
    final index = diagnoses.indexWhere((item) => item.id == diagnosis.id);

    if (index == -1) {
      diagnoses.add(diagnosis);
    } else {
      diagnoses[index] = diagnosis;
    }

    diagnoses.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final encoded = jsonEncode(diagnoses.map((item) => item.toJson()).toList());

    await _storage.saveString(_keyForScope(scope), encoded);
  }

  Future<void> deleteForPlant(String scope, String plantId) async {
    final diagnoses = loadDiagnoses(scope)
      ..removeWhere((diagnosis) => diagnosis.plantId == plantId);

    final encoded = jsonEncode(diagnoses.map((item) => item.toJson()).toList());

    await _storage.saveString(_keyForScope(scope), encoded);
  }
}
