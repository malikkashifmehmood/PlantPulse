import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plantpulse/core/models/plant_diagnosis.dart';
import 'package:plantpulse/core/storage/local_storage_service.dart';
import 'package:plantpulse/features/diagnosis/data/diagnosis_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DiagnosisRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    repository = DiagnosisRepository(LocalStorageService(preferences));
  });

  PlantDiagnosis createDiagnosis({
    String id = 'diagnosis-1',
    String plantId = 'plant-1',
    String plantName = 'Tomato Roma',
    String result = 'Early Blight',
    double confidence = 0.92,
    DateTime? createdAt,
  }) {
    return PlantDiagnosis(
      id: id,
      plantId: plantId,
      plantName: plantName,
      species: 'Tomato',
      result: result,
      confidence: confidence,
      symptoms: const ['Brown spots'],
      createdAt: createdAt ?? DateTime.utc(2026, 10, 20),
    );
  }

  test('returns an empty list when no diagnoses are saved', () {
    expect(repository.loadDiagnoses('guest'), isEmpty);
  });

  test('saves and loads a diagnosis', () async {
    final diagnosis = createDiagnosis();

    await repository.saveDiagnosis('guest', diagnosis);

    final loaded = repository.loadDiagnoses('guest');

    expect(loaded, hasLength(1));
    expect(loaded.single.id, diagnosis.id);
    expect(loaded.single.plantId, diagnosis.plantId);
    expect(loaded.single.plantName, diagnosis.plantName);
    expect(loaded.single.result, diagnosis.result);
    expect(loaded.single.confidence, diagnosis.confidence);
    expect(loaded.single.symptoms, diagnosis.symptoms);
    expect(loaded.single.createdAt, diagnosis.createdAt);
  });

  test('returns diagnoses newest first', () async {
    await repository.saveDiagnosis(
      'guest',
      createDiagnosis(id: 'old', createdAt: DateTime.utc(2026, 10, 18)),
    );
    await repository.saveDiagnosis(
      'guest',
      createDiagnosis(id: 'new', createdAt: DateTime.utc(2026, 10, 20)),
    );

    final loaded = repository.loadDiagnoses('guest');

    expect(loaded.map((item) => item.id), ['new', 'old']);
  });

  test('updates a diagnosis with the same ID', () async {
    await repository.saveDiagnosis('guest', createDiagnosis());
    await repository.saveDiagnosis(
      'guest',
      createDiagnosis(result: 'Healthy', confidence: 0.96),
    );

    final loaded = repository.loadDiagnoses('guest');

    expect(loaded, hasLength(1));
    expect(loaded.single.result, 'Healthy');
    expect(loaded.single.confidence, 0.96);
  });

  test('loads diagnoses for only the requested plant', () async {
    await repository.saveDiagnosis(
      'guest',
      createDiagnosis(id: 'tomato', plantId: 'plant-1'),
    );
    await repository.saveDiagnosis(
      'guest',
      createDiagnosis(
        id: 'pepper',
        plantId: 'plant-2',
        plantName: 'Pepper Plant',
      ),
    );

    final loaded = repository.loadForPlant('guest', 'plant-1');

    expect(loaded, hasLength(1));
    expect(loaded.single.id, 'tomato');
  });

  test('keeps different user scopes separate', () async {
    await repository.saveDiagnosis('guest', createDiagnosis());
    await repository.saveDiagnosis(
      'firebase-user-123',
      createDiagnosis(id: 'other-user-diagnosis'),
    );

    expect(repository.loadDiagnoses('guest').single.id, 'diagnosis-1');
    expect(
      repository.loadDiagnoses('firebase-user-123').single.id,
      'other-user-diagnosis',
    );
  });

  test('deletes diagnoses belonging to a plant only', () async {
    await repository.saveDiagnosis(
      'guest',
      createDiagnosis(id: 'tomato-1', plantId: 'plant-1'),
    );
    await repository.saveDiagnosis(
      'guest',
      createDiagnosis(id: 'tomato-2', plantId: 'plant-1'),
    );
    await repository.saveDiagnosis(
      'guest',
      createDiagnosis(id: 'pepper', plantId: 'plant-2'),
    );

    await repository.deleteForPlant('guest', 'plant-1');

    final loaded = repository.loadDiagnoses('guest');

    expect(loaded, hasLength(1));
    expect(loaded.single.id, 'pepper');
  });

  test('rejects an empty user scope', () {
    expect(() => repository.loadDiagnoses('  '), throwsArgumentError);
  });
}
