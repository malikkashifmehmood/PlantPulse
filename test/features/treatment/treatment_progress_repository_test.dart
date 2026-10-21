import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plantpulse/core/storage/local_storage_service.dart';
import 'package:plantpulse/features/treatment/data/treatment_progress_repository.dart';
import 'package:plantpulse/features/treatment/models/treatment_progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TreatmentProgressRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    repository = TreatmentProgressRepository(LocalStorageService(preferences));
  });

  TreatmentProgress createProgress({
    bool planStarted = true,
    Set<int> completedSteps = const {0, 2},
  }) {
    return TreatmentProgress(
      planStarted: planStarted,
      completedSteps: completedSteps,
      updatedAt: DateTime.utc(2026, 10, 21),
    );
  }

  test('returns null when no progress has been saved', () {
    expect(
      repository.loadProgress(
        scope: 'guest',
        contextId: 'plant-1:Tomato___Early_blight',
      ),
      isNull,
    );
  });

  test('saves and restores treatment progress', () async {
    final progress = createProgress();

    await repository.saveProgress(
      scope: 'guest',
      contextId: 'plant-1:Tomato___Early_blight',
      progress: progress,
    );

    final loaded = repository.loadProgress(
      scope: 'guest',
      contextId: 'plant-1:Tomato___Early_blight',
    );

    expect(loaded, isNotNull);
    expect(loaded!.planStarted, isTrue);
    expect(loaded.completedSteps, {0, 2});
    expect(loaded.updatedAt, progress.updatedAt);
  });

  test('keeps different user scopes separate', () async {
    await repository.saveProgress(
      scope: 'guest',
      contextId: 'plant-1:Tomato___Early_blight',
      progress: createProgress(completedSteps: {0}),
    );

    await repository.saveProgress(
      scope: 'firebase-user-123',
      contextId: 'plant-1:Tomato___Early_blight',
      progress: createProgress(completedSteps: {1, 2}),
    );

    expect(
      repository
          .loadProgress(
            scope: 'guest',
            contextId: 'plant-1:Tomato___Early_blight',
          )!
          .completedSteps,
      {0},
    );

    expect(
      repository
          .loadProgress(
            scope: 'firebase-user-123',
            contextId: 'plant-1:Tomato___Early_blight',
          )!
          .completedSteps,
      {1, 2},
    );
  });

  test('keeps different treatment contexts separate', () async {
    await repository.saveProgress(
      scope: 'guest',
      contextId: 'plant-1:Tomato___Early_blight',
      progress: createProgress(completedSteps: {0}),
    );

    await repository.saveProgress(
      scope: 'guest',
      contextId: 'plant-2:Tomato___Early_blight',
      progress: createProgress(completedSteps: {2}),
    );

    expect(
      repository
          .loadProgress(
            scope: 'guest',
            contextId: 'plant-1:Tomato___Early_blight',
          )!
          .completedSteps,
      {0},
    );

    expect(
      repository
          .loadProgress(
            scope: 'guest',
            contextId: 'plant-2:Tomato___Early_blight',
          )!
          .completedSteps,
      {2},
    );
  });

  test('deletes saved treatment progress', () async {
    const contextId = 'plant-1:Tomato___Early_blight';

    await repository.saveProgress(
      scope: 'guest',
      contextId: contextId,
      progress: createProgress(),
    );

    await repository.deleteProgress(scope: 'guest', contextId: contextId);

    expect(
      repository.loadProgress(scope: 'guest', contextId: contextId),
      isNull,
    );
  });
}
