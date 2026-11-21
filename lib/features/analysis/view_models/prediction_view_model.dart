import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../core/network/plantpulse_api.dart';
import '../data/prediction_repository.dart';

class PredictionViewModel extends ChangeNotifier {
  PredictionViewModel(this._repository);

  final PredictionRepository _repository;

  bool isLoading = false;
  PlantPulsePrediction? prediction;
  String? errorMessage;

  bool _disposed = false;

  Future<void> predict(File imageFile) async {
    if (_disposed || isLoading) return;

    isLoading = true;
    prediction = null;
    errorMessage = null;
    notifyListeners();

    try {
      prediction = await _repository.predictImage(imageFile);
    } catch (error) {
      errorMessage = _readableError(error);
    } finally {
      isLoading = false;

      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  String _readableError(Object error) {
    if (error is PlantPulseApiException) {
      return error.message;
    }

    return 'Unable to analyze this image. Please try again.';
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
