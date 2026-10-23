import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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
      throw const FormatException(
        'The prediction API returned an invalid response.',
      );
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
  // Android emulator address for the API running on your PC.
  static const String baseUrl = 'http://10.252.64.83:8000';

  static const int maxImageBytes = 8 * 1024 * 1024;

  Future<PlantPulsePrediction> predict(File imageFile) async {
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

    // Explicitly determine the supported image MIME type.
    final extension = imageFile.path.split('.').last.toLowerCase();

    final MediaType mediaType;

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        mediaType = MediaType('image', 'jpeg');
        break;
      case 'png':
        mediaType = MediaType('image', 'png');
        break;
      case 'webp':
        mediaType = MediaType('image', 'webp');
        break;
      default:
        throw const PlantPulseApiException(
          'Please select a JPEG, PNG, or WebP image.',
        );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/predict'),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: mediaType,
      ),
    );

    try {
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );

      final response = await http.Response.fromStream(streamedResponse);

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        throw const PlantPulseApiException(
          'The prediction server returned an invalid response.',
        );
      }

      if (response.statusCode != 200) {
        final message =
            decoded is Map && decoded['detail'] is String
                ? decoded['detail'] as String
                : 'Prediction failed. Please try again.';

        throw PlantPulseApiException(message);
      }

      if (decoded is! Map<String, dynamic>) {
        throw const PlantPulseApiException(
          'The prediction server returned an invalid response.',
        );
      }

      return PlantPulsePrediction.fromJson(decoded);
    } on PlantPulseApiException {
      rethrow;
    } on SocketException {
      throw const PlantPulseApiException(
        'Cannot reach the prediction server. '
        'Check that FastAPI is running.',
      );
    } on http.ClientException {
      throw const PlantPulseApiException(
        'Network error while contacting the prediction server.',
      );
    } on FormatException {
      throw const PlantPulseApiException(
        'The prediction response could not be processed.',
      );
    } on Exception {
      throw const PlantPulseApiException(
        'The prediction request failed. Please try again.',
      );
    }
  }
}
