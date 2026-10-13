import 'dart:convert';

import '../../../core/models/plant.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/storage_keys.dart';

class PlantRepository {
  PlantRepository(this._storage);

  final LocalStorageService _storage;

  String _keyForScope(String scope) {
    final normalizedScope = scope.trim();

    if (normalizedScope.isEmpty) {
      throw ArgumentError.value(scope, 'scope', 'Must not be empty.');
    }

    return '${StorageKeys.cachedPlants}_${Uri.encodeComponent(normalizedScope)}';
  }

  List<Plant> loadPlants(String scope) {
    final json = _storage.readString(_keyForScope(scope));

    if (json == null || json.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(json);

      if (decoded is! List) {
        throw const FormatException('Stored plants must be a list.');
      }

      return decoded.map<Plant>((item) {
        if (item is! Map) {
          throw const FormatException('Invalid plant record.');
        }

        final record = Map<String, dynamic>.from(item);

        return Plant(
          id: record['id'] as String,
          name: record['name'] as String,
          species: record['species'] as String,
          createdAt: DateTime.parse(record['createdAt'] as String),
        );
      }).toList();
    } catch (_) {
      throw const FormatException(
        'Saved plant data is invalid or cannot be decoded.',
      );
    }
  }

  Future<void> savePlant(String scope, Plant plant) async {
    final key = _keyForScope(scope);
    final plants = loadPlants(scope);
    final index = plants.indexWhere((item) => item.id == plant.id);

    if (index == -1) {
      plants.add(plant);
    } else {
      plants[index] = plant;
    }

    final encoded = jsonEncode(
      plants
          .map(
            (item) => {
              'id': item.id,
              'name': item.name,
              'species': item.species,
              'createdAt': item.createdAt.toIso8601String(),
            },
          )
          .toList(),
    );

    await _storage.saveString(key, encoded);
  }

  Future<void> deletePlant(String scope, String plantId) async {
    final key = _keyForScope(scope);
    final plants = loadPlants(scope)
      ..removeWhere((plant) => plant.id == plantId);

    final encoded = jsonEncode(
      plants
          .map(
            (item) => {
              'id': item.id,
              'name': item.name,
              'species': item.species,
              'createdAt': item.createdAt.toIso8601String(),
            },
          )
          .toList(),
    );

    await _storage.saveString(key, encoded);
  }
}
