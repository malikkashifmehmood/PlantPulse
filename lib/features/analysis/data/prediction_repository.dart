import 'dart:io';

import '../../../core/network/plantpulse_api.dart';

class PredictionRepository {
  PredictionRepository(this._api);

  final PlantPulseApi _api;

  Future<PlantPulsePrediction> predictImage(File imageFile) {
    return _api.predict(imageFile);
  }
}
