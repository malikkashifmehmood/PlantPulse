enum ScanStatus { pending, analyzing, completed, lowConfidence, failed }

class Scan {
  final String id;
  final String plantId;
  final String imagePath;
  final ScanStatus status;
  final String? diagnosisId;
  final DateTime createdAt;

  const Scan({
    required this.id,
    required this.plantId,
    required this.imagePath,
    required this.status,
    this.diagnosisId,
    required this.createdAt,
  });
}
