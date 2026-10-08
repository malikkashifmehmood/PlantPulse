enum DiagnosisConfidence { high, medium, low }

class Diagnosis {
  final String id;
  final String plantId;
  final String diseaseName;
  final double confidence;
  final DiagnosisConfidence confidenceLevel;
  final List<String> symptoms;
  final DateTime createdAt;

  const Diagnosis({
    required this.id,
    required this.plantId,
    required this.diseaseName,
    required this.confidence,
    required this.confidenceLevel,
    required this.symptoms,
    required this.createdAt,
  });
}
