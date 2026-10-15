class PlantDiagnosis {
  final String id;
  final String plantId;
  final String plantName;
  final String species;
  final String result;
  final double confidence;
  final List<String> symptoms;
  final DateTime createdAt;

  const PlantDiagnosis({
    required this.id,
    required this.plantId,
    required this.plantName,
    required this.species,
    required this.result,
    required this.confidence,
    required this.symptoms,
    required this.createdAt,
  });

  bool get isHealthy => result.toLowerCase() == 'healthy';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'plantName': plantName,
      'species': species,
      'result': result,
      'confidence': confidence,
      'symptoms': symptoms,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PlantDiagnosis.fromJson(Map<String, dynamic> json) {
    final confidenceValue = json['confidence'];

    if (confidenceValue is! num) {
      throw const FormatException('Invalid diagnosis confidence.');
    }

    final symptomsValue = json['symptoms'];

    if (symptomsValue is! List) {
      throw const FormatException('Invalid diagnosis symptoms.');
    }

    return PlantDiagnosis(
      id: json['id'] as String,
      plantId: json['plantId'] as String,
      plantName: json['plantName'] as String,
      species: json['species'] as String,
      result: json['result'] as String,
      confidence: confidenceValue.toDouble(),
      symptoms: symptomsValue.cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
