import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_theme.dart';
import '../../core/models/plant.dart';
import '../../core/models/plant_diagnosis.dart';
import '../../shared/widgets/plantpulse_scaffold.dart';
import '../expert/expert_screen.dart';
import '../treatment/treatment_screen.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key, this.plant});

  final Plant? plant;

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  bool _saving = false;
  bool _saved = false;
  bool _saveAttempted = false;

  String get _scope => FirebaseAuth.instance.currentUser?.uid ?? 'guest';

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

    _saving = true;
    _saveAttempted = true;

    try {
      final diagnosis = PlantDiagnosis(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        plantId: plant.id,
        plantName: plant.name,
        species: plant.species,
        result: 'Early Blight',
        confidence: 0.92,
        symptoms: const [
          'Circular brown lesions',
          'Yellowing around affected areas',
          'Leaf deterioration',
        ],
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
        SnackBar(content: Text('Diagnosis saved for ${plant.name}.')),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save diagnosis. Please try Save again.'),
        ),
      );
    } finally {
      _saving = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final plant = widget.plant;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Diagnosis'),
        actions: [
          IconButton(
            onPressed: _saving ? null : _saveDiagnosis,
            icon: Icon(
              _saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            ),
            tooltip: _saved ? 'Saved' : 'Save diagnosis',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 230,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8F4DF), Color(0xFFBCDCA9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.eco_rounded,
                  size: 100,
                  color: PlantPulseColors.green,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Early Blight',
                    style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900),
                  ),
                ),
                StatusPill(
                  text: '92% confidence',
                  background: PlantPulseColors.successBg,
                  foreground: PlantPulseColors.green,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plant == null
                  ? 'Demo result • No plant selected'
                  : '${plant.name} • ${plant.species}',
              style: const TextStyle(
                color: PlantPulseColors.muted,
                fontSize: 12,
              ),
            ),
            if (plant != null) ...[
              const SizedBox(height: 5),
              Text(
                _saved
                    ? 'Diagnosis saved to this plant’s history'
                    : _saving
                    ? 'Saving diagnosis...'
                    : 'Diagnosis will be saved to this plant’s history',
                style: TextStyle(
                  color:
                      _saved ? PlantPulseColors.green : PlantPulseColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 20),
            const _ConfidenceCard(),
            const SizedBox(height: 18),
            const Text(
              'Visible symptoms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            const _Symptom(text: 'Circular brown lesions'),
            const _Symptom(text: 'Yellowing around affected areas'),
            const _Symptom(text: 'Leaf deterioration'),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PlantPulseColors.warningBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: PlantPulseColors.warning,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Demo diagnosis: the disease and confidence shown '
                      'are sample values, not predictions from a trained '
                      'plant-detection model.',
                      style: TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const TreatmentScreen(),
                    ),
                  ),
              child: const Text('View Treatment Plan'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saving ? null : _saveDiagnosis,
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
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const ExpertScreen(),
                          ),
                        ),
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

class _ConfidenceCard extends StatelessWidget {
  const _ConfidenceCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 62,
              height: 62,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: .92,
                    strokeWidth: 7,
                    color: PlantPulseColors.green,
                    backgroundColor: PlantPulseColors.mint,
                  ),
                  const Text(
                    '92',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Demo confidence',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'The displayed percentage is a sample value. '
                    'Real confidence requires an actual model prediction.',
                    style: TextStyle(
                      color: PlantPulseColors.muted,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Symptom extends StatelessWidget {
  const _Symptom({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: PlantPulseColors.green,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
