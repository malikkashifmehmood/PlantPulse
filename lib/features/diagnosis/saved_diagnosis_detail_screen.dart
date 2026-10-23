import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/models/plant_diagnosis.dart';

class SavedDiagnosisDetailScreen extends StatelessWidget {
  const SavedDiagnosisDetailScreen({super.key, required this.diagnosis});

  final PlantDiagnosis diagnosis;

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final confidence = (diagnosis.confidence * 100).round();
    final healthy = diagnosis.isHealthy;

    return Scaffold(
      appBar: AppBar(title: const Text('Diagnosis Details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF274B2F), Color(0xFF75A861)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Icon(
                  healthy
                      ? Icons.check_circle_rounded
                      : Icons.health_and_safety_rounded,
                  color: Colors.white,
                  size: 54,
                ),
                const SizedBox(height: 14),
                Text(
                  diagnosis.result,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$confidence% model score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.local_florist_outlined,
                    color: PlantPulseColors.green,
                  ),
                  title: const Text('Plant'),
                  subtitle: Text(diagnosis.plantName),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.category_outlined,
                    color: PlantPulseColors.green,
                  ),
                  title: const Text('Species'),
                  subtitle: Text(diagnosis.species),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.calendar_today_outlined,
                    color: PlantPulseColors.green,
                  ),
                  title: const Text('Scan date'),
                  subtitle: Text(_formatDate(diagnosis.createdAt)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Recorded symptoms',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child:
                  diagnosis.symptoms.isEmpty
                      ? const Text(
                        'No symptoms were recorded for this scan.',
                        style: TextStyle(
                          color: PlantPulseColors.muted,
                          height: 1.5,
                        ),
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            diagnosis.symptoms
                                .map(
                                  (symptom) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.circle,
                                          size: 8,
                                          color: PlantPulseColors.green,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(child: Text(symptom)),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PlantPulseColors.warningBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: PlantPulseColors.warning,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This is a saved AI model prediction, not a confirmed '
                    'diagnosis. The model score is not a calibrated '
                    'probability of being correct. Check the plant carefully '
                    'and seek expert advice if symptoms persist.',
                    style: TextStyle(height: 1.5, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
