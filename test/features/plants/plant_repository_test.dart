import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plantpulse/core/models/plant.dart';
import 'package:plantpulse/core/storage/local_storage_service.dart';
import 'package:plantpulse/features/plants/data/plant_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PlantRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    repository = PlantRepository(LocalStorageService(preferences));
  });

  Plant createPlant({
    String id = 'plant-1',
    String name = 'Tomato Roma',
    String species = 'Tomato',
  }) {
    return Plant(
      id: id,
      name: name,
      species: species,
      createdAt: DateTime.utc(2026, 10, 13),
    );
  }

  test('returns an empty list when no plants are saved', () {
    expect(repository.loadPlants('guest'), isEmpty);
  });

  test('saves and loads a plant', () async {
    final plant = createPlant();

    await repository.savePlant('guest', plant);

    final loaded = repository.loadPlants('guest');

    expect(loaded, hasLength(1));
    expect(loaded.single.id, plant.id);
    expect(loaded.single.name, plant.name);
    expect(loaded.single.species, plant.species);
    expect(loaded.single.createdAt, plant.createdAt);
  });

  test('updates an existing plant with the same ID', () async {
    await repository.savePlant('guest', createPlant());
    await repository.savePlant('guest', createPlant(name: 'Updated Tomato'));

    final loaded = repository.loadPlants('guest');

    expect(loaded, hasLength(1));
    expect(loaded.single.name, 'Updated Tomato');
  });

  test('keeps different user scopes separate', () async {
    await repository.savePlant('guest', createPlant());
    await repository.savePlant(
      'firebase-user-123',
      createPlant(id: 'plant-2', name: 'Pepper'),
    );

    expect(repository.loadPlants('guest').single.name, 'Tomato Roma');
    expect(repository.loadPlants('firebase-user-123').single.name, 'Pepper');
  });

  test('deletes a plant by ID', () async {
    await repository.savePlant('guest', createPlant());
    await repository.savePlant(
      'guest',
      createPlant(id: 'plant-2', name: 'Pepper'),
    );

    await repository.deletePlant('guest', 'plant-1');

    final loaded = repository.loadPlants('guest');

    expect(loaded, hasLength(1));
    expect(loaded.single.id, 'plant-2');
  });
}
