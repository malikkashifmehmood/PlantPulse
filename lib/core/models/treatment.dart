class TreatmentStep {
  final String id;
  final String title;
  final String description;
  final int day;
  final bool completed;

  const TreatmentStep({
    required this.id,
    required this.title,
    required this.description,
    required this.day,
    required this.completed,
  });
}

class TreatmentPlan {
  final String id;
  final String diagnosisId;
  final String title;
  final List<TreatmentStep> steps;
  final DateTime createdAt;

  const TreatmentPlan({
    required this.id,
    required this.diagnosisId,
    required this.title,
    required this.steps,
    required this.createdAt,
  });
}
