import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_theme.dart';
import '../../core/models/plant.dart';
import '../../core/models/plant_diagnosis.dart';
import '../../core/network/plantpulse_api.dart';
import '../expert/expert_screen.dart';
import '../treatment/treatment_screen.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({
    super.key,
    required this.prediction,
    required this.imageFile,
    this.plant,
  });

  final Plant? plant;
  final PlantPulsePrediction prediction;
  final File imageFile;

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  bool _saving = false;
  bool _saved = false;
  bool _saveAttempted = false;

  String get _scope => FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  double get _confidence =>
      widget.prediction.confidence.clamp(0.0, 1.0).toDouble();

  bool get _isHealthy => widget.prediction.predictedClass == 'Tomato___healthy';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.plant != null) {
        _saveDiagnosis();
      }
    });
  }

  Future<void> _saveDiagnosis() async {
    final plant = widget.plant;

    if (plant == null || _saving || _saved || _saveAttempted) {
      return;
    }

    setState(() {
      _saving = true;
      _saveAttempted = true;
    });

    try {
      final diagnosis = PlantDiagnosis(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        plantId: plant.id,
        plantName: plant.name,
        species: plant.species,
        result: widget.prediction.displayName,
        confidence: _confidence,
        symptoms: const [],
        createdAt: DateTime.now(),
      );

      await AppServicesScope.of(
        context,
      ).diagnoses.saveDiagnosis(_scope, diagnosis);

      if (!mounted) return;

      setState(() {
        _saved = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Prediction saved for ${plant.name}.')),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saveAttempted = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save prediction. Please try Save again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plant = widget.plant;
    final confidencePercent = (_confidence * 100).round();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Diagnosis'),
        actions: [
          IconButton(
            onPressed: _saving || _saved ? null : _saveDiagnosis,
            icon: Icon(
              _saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            ),
            tooltip: _saved ? 'Saved' : 'Save prediction',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Image.file(
                widget.imageFile,
                width: double.infinity,
                height: 230,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      height: 230,
                      width: double.infinity,
                      color: PlantPulseColors.mint,
                      child: const Icon(
                        Icons.eco_rounded,
                        size: 80,
                        color: PlantPulseColors.green,
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.prediction.displayName,
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              plant == null
                  ? 'AI model prediction'
                  : '${plant.name} • ${plant.species}',
              style: const TextStyle(
                color: PlantPulseColors.muted,
                fontSize: 12,
              ),
            ),
            if (plant != null) ...[
              const SizedBox(height: 6),
              Text(
                _saved
                    ? 'Prediction saved to this plant’s history'
                    : _saving
                    ? 'Saving prediction...'
                    : 'Prediction will be saved to this plant’s history',
                style: TextStyle(
                  color:
                      _saved ? PlantPulseColors.green : PlantPulseColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 66,
                      height: 66,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _confidence,
                            strokeWidth: 7,
                            color: PlantPulseColors.green,
                            backgroundColor: PlantPulseColors.mint,
                          ),
                          Text(
                            '$confidencePercent%',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Model score',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Model: ${widget.prediction.model}',
                            style: const TextStyle(
                              color: PlantPulseColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Prediction details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              _isHealthy
                  ? 'The model classified this image as a healthy tomato leaf.'
                  : 'The model classified this image as '
                      '${widget.prediction.displayName}. '
                      'Use this result as an initial indication, not a confirmed diagnosis.',
              style: const TextStyle(height: 1.5),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PlantPulseColors.warningBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: PlantPulseColors.warning,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      '${widget.prediction.notice} '
                      'The model score is not a calibrated probability of '
                      'being correct. This model has not been validated here '
                      'on field images from Pakistan.',
                      style: const TextStyle(fontSize: 12, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const TreatmentScreen(),
                    ),
                  );
                },
                child: const Text('View Treatment Plan'),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saving || _saved ? null : _saveDiagnosis,
                    icon: Icon(
                      _saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                    ),
                    label: Text(
                      _saving
                          ? 'Saving...'
                          : _saved
                          ? 'Saved'
                          : 'Save',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const ExpertScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.support_agent_rounded),
                    label: const Text('Expert'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
