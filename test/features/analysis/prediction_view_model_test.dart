import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:plantpulse/core/network/plantpulse_api.dart';
import 'package:plantpulse/features/analysis/data/prediction_repository.dart';
import 'package:plantpulse/features/analysis/view_models/prediction_view_model.dart';

class FakePredictionRepository extends PredictionRepository {
  FakePredictionRepository() : super(PlantPulseApi());

  Future<PlantPulsePrediction> Function(File imageFile)? onPredict;

  @override
  Future<PlantPulsePrediction> predictImage(File imageFile) {
    return onPredict!(imageFile);
  }
}

void main() {
  const prediction = PlantPulsePrediction(
    predictedClass: 'Tomato___Early_blight',
    confidence: 0.92,
    probabilities: {'Tomato___Early_blight': 0.92, 'Tomato___healthy': 0.08},
    model: 'MobileNetV3Small-finetuned',
    notice: 'AI prediction only.',
  );

  late FakePredictionRepository repository;
  late PredictionViewModel viewModel;

  setUp(() {
    repository = FakePredictionRepository();
    viewModel = PredictionViewModel(repository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('starts with an empty prediction and no error', () {
    expect(viewModel.isLoading, isFalse);
    expect(viewModel.prediction, isNull);
    expect(viewModel.errorMessage, isNull);
  });

  test('sets loading state and stores a successful prediction', () async {
    final completer = Completer<PlantPulsePrediction>();

    repository.onPredict = (_) => completer.future;

    final request = viewModel.predict(File('test_image.jpg'));

    expect(viewModel.isLoading, isTrue);
    expect(viewModel.prediction, isNull);
    expect(viewModel.errorMessage, isNull);

    completer.complete(prediction);

    await request;

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.prediction, same(prediction));
    expect(viewModel.errorMessage, isNull);
  });

  test('exposes API error messages', () async {
    repository.onPredict = (_) async {
      throw const PlantPulseApiException('Server is unavailable.');
    };

    await viewModel.predict(File('test_image.jpg'));

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.prediction, isNull);
    expect(viewModel.errorMessage, 'Server is unavailable.');
  });

  test('prevents a second prediction while one is running', () async {
    final completer = Completer<PlantPulsePrediction>();
    var requestCount = 0;

    repository.onPredict = (_) {
      requestCount++;
      return completer.future;
    };

    final firstRequest = viewModel.predict(File('first.jpg'));
    await viewModel.predict(File('second.jpg'));

    expect(requestCount, 1);

    completer.complete(prediction);
    await firstRequest;

    expect(viewModel.prediction, same(prediction));
  });
}
