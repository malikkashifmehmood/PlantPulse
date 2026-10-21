class TreatmentProgress {
  const TreatmentProgress({
    required this.planStarted,
    required this.completedSteps,
    required this.updatedAt,
  });

  final bool planStarted;
  final Set<int> completedSteps;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    final sortedSteps = completedSteps.toList()..sort();

    return {
      'planStarted': planStarted,
      'completedSteps': sortedSteps,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TreatmentProgress.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['completedSteps'];
    final rawUpdatedAt = json['updatedAt'];

    if (json['planStarted'] is! bool ||
        rawSteps is! List ||
        rawUpdatedAt is! String) {
      throw const FormatException('Invalid treatment progress data.');
    }

    final steps = <int>{};

    for (final value in rawSteps) {
      if (value is! int || value < 0) {
        throw const FormatException('Invalid treatment checklist step.');
      }

      steps.add(value);
    }

    final updatedAt = DateTime.tryParse(rawUpdatedAt);

    if (updatedAt == null) {
      throw const FormatException('Invalid treatment progress date.');
    }

    return TreatmentProgress(
      planStarted: json['planStarted'] as bool,
      completedSteps: Set<int>.unmodifiable(steps),
      updatedAt: updatedAt,
    );
  }
}
