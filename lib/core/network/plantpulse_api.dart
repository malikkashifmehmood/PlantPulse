import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_litert/flutter_litert.dart';

class PlantPulsePrediction {
  final String predictedClass;
  final double confidence;
  final Map<String, double> probabilities;
  final String model;
  final String notice;

  const PlantPulsePrediction({
    required this.predictedClass,
    required this.confidence,
    required this.probabilities,
    required this.model,
    required this.notice,
  });

  String get displayName {
    const names = <String, String>{
      'Tomato___Bacterial_spot': 'Bacterial Spot',
      'Tomato___Early_blight': 'Early Blight',
      'Tomato___Late_blight': 'Late Blight',
      'Tomato___Leaf_Mold': 'Leaf Mold',
      'Tomato___Septoria_leaf_spot': 'Septoria Leaf Spot',
      'Tomato___Spider_mites Two-spotted_spider_mite': 'Spider Mites',
      'Tomato___Target_Spot': 'Target Spot',
      'Tomato___Tomato_Yellow_Leaf_Curl_Virus': 'Yellow Leaf Curl Virus',
      'Tomato___Tomato_mosaic_virus': 'Tomato Mosaic Virus',
      'Tomato___healthy': 'Healthy Tomato Leaf',
    };

    return names[predictedClass] ?? predictedClass;
  }

  factory PlantPulsePrediction.fromJson(Map<String, dynamic> json) {
    final rawProbabilities = json['probabilities'];
    final rawConfidence = json['confidence'];

    if (json['predicted_class'] is! String ||
        rawConfidence is! num ||
        rawProbabilities is! Map) {
      throw const FormatException('The prediction response is invalid.');
    }

    final probabilities = <String, double>{};

    for (final entry in rawProbabilities.entries) {
      if (entry.key is String && entry.value is num) {
        probabilities[entry.key as String] = (entry.value as num).toDouble();
      }
    }

    return PlantPulsePrediction(
      predictedClass: json['predicted_class'] as String,
      confidence: rawConfidence.toDouble(),
      probabilities: probabilities,
      model: json['model'] as String? ?? 'Unknown model',
      notice:
          json['notice'] as String? ??
          'AI prediction only. Results may be unreliable.',
    );
  }
}

class PlantPulseApiException implements Exception {
  final String message;

  const PlantPulseApiException(this.message);

  @override
  String toString() => message;
}

class PlantPulseApi {
  static const String modelAsset =
      'assets/models/plantpulse_finetuned_best.tflite';

  static const String classNamesAsset = 'assets/models/class_names.json';

  static const int imageWidth = 224;
  static const int imageHeight = 224;
  static const int inputElements = imageWidth * imageHeight * 3;

  static const int expectedClasses = 10;
  static const int maxImageBytes = 8 * 1024 * 1024;
  static const int maxImagePixels = 20000000;

  static const String modelName = 'MobileNetV3Small-finetuned';

  static const String predictionNotice =
      'AI prediction only. Results may be unreliable for field images '
      'outside the training dataset.';

  Future<Interpreter>? _interpreterFuture;
  Future<List<String>>? _classNamesFuture;

  // Keep inference sequential because the interpreter is shared.
  Future<void> _inferenceQueue = Future<void>.value();

  Future<T> _runExclusive<T>(Future<T> Function() operation) {
    final completer = Completer<T>();

    _inferenceQueue = _inferenceQueue.then((_) async {
      try {
        completer.complete(await operation());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });

    return completer.future;
  }

  Future<Interpreter> _loadInterpreter() async {
    final future = _interpreterFuture ??= _createInterpreter();

    try {
      return await future;
    } catch (_) {
      if (identical(_interpreterFuture, future)) {
        _interpreterFuture = null;
      }
      rethrow;
    }
  }

  Future<Interpreter> _createInterpreter() async {
    try {
      final interpreter = await Interpreter.fromAsset(modelAsset);

      final inputShape = interpreter.getInputTensor(0).shape;
      final outputShape = interpreter.getOutputTensor(0).shape;

      if (!_sameShape(inputShape, [1, imageHeight, imageWidth, 3]) ||
          !_sameShape(outputShape, [1, expectedClasses])) {
        interpreter.close();

        throw const PlantPulseApiException(
          'The installed AI model has an unexpected input or output shape.',
        );
      }

      return interpreter;
    } on PlantPulseApiException {
      rethrow;
    } catch (_) {
      throw const PlantPulseApiException(
        'Could not load the on-device AI model.',
      );
    }
  }

  bool _sameShape(List<int> actual, List<int> expected) {
    if (actual.length != expected.length) return false;

    for (var i = 0; i < actual.length; i++) {
      if (actual[i] != expected[i]) return false;
    }

    return true;
  }

  Future<List<String>> _loadClassNames() async {
    final future = _classNamesFuture ??= _readClassNames();

    try {
      return await future;
    } catch (_) {
      if (identical(_classNamesFuture, future)) {
        _classNamesFuture = null;
      }
      rethrow;
    }
  }

  Future<List<String>> _readClassNames() async {
    try {
      final contents = await rootBundle.loadString(classNamesAsset);
      final decoded = jsonDecode(contents);

      if (decoded is! List ||
          decoded.length != expectedClasses ||
          decoded.any((value) => value is! String || value.isEmpty)) {
        throw const FormatException('Invalid class names.');
      }

      final names = decoded.cast<String>();

      if (names.toSet().length != expectedClasses) {
        throw const FormatException('Duplicate class names.');
      }

      return List<String>.unmodifiable(names);
    } catch (_) {
      throw const PlantPulseApiException(
        'Could not load the AI model class names.',
      );
    }
  }

  Future<PlantPulsePrediction> predict(File imageFile) {
    return _runExclusive(() async {
      if (!await imageFile.exists()) {
        throw const PlantPulseApiException('The selected image was not found.');
      }

      final imageSize = await imageFile.length();

      if (imageSize == 0) {
        throw const PlantPulseApiException('The selected image is empty.');
      }

      if (imageSize > maxImageBytes) {
        throw const PlantPulseApiException('Image must be 8 MB or smaller.');
      }

      final bytes = await imageFile.readAsBytes();

      final input = await _prepareImage(bytes);
      final interpreter = await _loadInterpreter();
      final classNames = await _loadClassNames();

      final output = Float32List(expectedClasses);

      try {
        interpreter.run(input, output);
      } catch (_) {
        throw const PlantPulseApiException(
          'The on-device AI model could not analyze this image.',
        );
      }

      return _buildPrediction(output, classNames);
    });
  }

  Future<Float32List> _prepareImage(Uint8List bytes) async {
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    ui.Image? image;

    try {
      buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      descriptor = await ui.ImageDescriptor.encoded(buffer);

      if (descriptor.width <= 0 || descriptor.height <= 0) {
        throw const FormatException('Invalid image dimensions.');
      }

      final pixelCount = descriptor.width * descriptor.height;

      if (pixelCount > maxImagePixels) {
        throw const PlantPulseApiException(
          'Image dimensions are too large to process safely.',
        );
      }

      codec = await descriptor.instantiateCodec(
        targetWidth: imageWidth,
        targetHeight: imageHeight,
      );

      if (codec.frameCount != 1) {
        throw const PlantPulseApiException(
          'Animated images are not supported. Select a still image.',
        );
      }

      final frame = await codec.getNextFrame();
      image = frame.image;

      if (image.width != imageWidth || image.height != imageHeight) {
        throw const FormatException('Image could not be resized correctly.');
      }

      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      if (byteData == null) {
        throw const FormatException('Could not read image pixels.');
      }

      final rgba = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );

      final input = Float32List(inputElements);

      var destination = 0;

      for (var source = 0; source < rgba.length; source += 4) {
        // Preserve RGB channel order and raw 0–255 pixel values.
        // The model handles its own built-in preprocessing.
        input[destination++] = rgba[source].toDouble();
        input[destination++] = rgba[source + 1].toDouble();
        input[destination++] = rgba[source + 2].toDouble();
      }

      return input;
    } on PlantPulseApiException {
      rethrow;
    } catch (_) {
      throw const PlantPulseApiException(
        'The selected file is not a supported or valid image.',
      );
    } finally {
      image?.dispose();
      codec?.dispose();
      descriptor?.dispose();
      buffer?.dispose();
    }
  }

  PlantPulsePrediction _buildPrediction(
    Float32List output,
    List<String> classNames,
  ) {
    if (output.length != expectedClasses) {
      throw const PlantPulseApiException(
        'The AI model returned an invalid result.',
      );
    }

    var probabilitySum = 0.0;
    var bestIndex = 0;
    var bestConfidence = -1.0;

    final probabilities = <String, double>{};

    for (var i = 0; i < expectedClasses; i++) {
      final value = output[i].toDouble();

      if (!value.isFinite || value < 0 || value > 1) {
        throw const PlantPulseApiException(
          'The AI model returned invalid probability values.',
        );
      }

      probabilities[classNames[i]] = value;
      probabilitySum += value;

      if (value > bestConfidence) {
        bestConfidence = value;
        bestIndex = i;
      }
    }

    if ((probabilitySum - 1.0).abs() > 0.001) {
      throw const PlantPulseApiException(
        'The AI model returned an invalid probability distribution.',
      );
    }

    return PlantPulsePrediction(
      predictedClass: classNames[bestIndex],
      confidence: bestConfidence,
      probabilities: Map.unmodifiable(probabilities),
      model: modelName,
      notice: predictionNotice,
    );
  }
}
