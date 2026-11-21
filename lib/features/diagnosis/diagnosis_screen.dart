import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_theme.dart';
import '../../core/models/plant.dart';
import '../../core/models/plant_diagnosis.dart';
import '../../core/network/plantpulse_api.dart';
import '../../l10n/app_localizations.dart';
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

  String get _scope {
    if (Firebase.apps.isEmpty) return 'guest';
    return FirebaseAuth.instance.currentUser?.uid ?? 'guest';
  }

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

      final l10n = AppLocalizations.of(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.diagnosisSavedForPlant(plant.name))),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saveAttempted = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).diagnosisSaveFailed),
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

  void _openTreatmentPlan() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder:
            (_) => TreatmentScreen(
              prediction: widget.prediction,
              plantName: widget.plant?.name,
              species: widget.plant?.species,
              plantId: widget.plant?.id,
              userScope: _scope,
            ),
      ),
    );
  }

  void _openExpert() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const ExpertScreen()),
    );
  }

  Widget _buildImage(double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.file(
        widget.imageFile,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: double.infinity,
            height: height,
            color: PlantPulseColors.mint,
            alignment: Alignment.center,
            child: const Icon(
              Icons.eco_rounded,
              size: 76,
              color: PlantPulseColors.green,
            ),
          );
        },
      ),
    );
  }

  Widget _buildConfidenceCard(int confidencePercent, AppLocalizations l10n) {
    return Card(
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.diagnosisModelScore,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    l10n.diagnosisModelName(widget.prediction.model),
                    style: const TextStyle(
                      color: PlantPulseColors.muted,
                      fontSize: 12,
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

  Widget _buildNotice(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PlantPulseColors.warningBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 21,
            color: PlantPulseColors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${widget.prediction.notice} ${l10n.diagnosisNotice}',
              style: const TextStyle(fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveStatus(AppLocalizations l10n) {
    if (widget.plant == null) {
      return const SizedBox.shrink();
    }

    final String message;
    final Color color;

    if (_saved) {
      message = l10n.diagnosisSavedHistory;
      color = PlantPulseColors.green;
    } else if (_saving) {
      message = l10n.diagnosisSavingHistory;
      color = PlantPulseColors.muted;
    } else {
      message = l10n.diagnosisWillSaveHistory;
      color = PlantPulseColors.muted;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Text(
        message,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: _openTreatmentPlan,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Text(l10n.diagnosisViewTreatment),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (widget.plant != null) ...[
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
                        ? l10n.diagnosisSaving
                        : _saved
                        ? l10n.diagnosisSaved
                        : l10n.diagnosisSave,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _openExpert,
                icon: const Icon(Icons.support_agent_rounded),
                label: Text(l10n.diagnosisExpert),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plant = widget.plant;
    final confidencePercent = (_confidence * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.diagnosisTitle),
        actions: [
          if (plant != null)
            IconButton(
              onPressed: _saving || _saved ? null : _saveDiagnosis,
              icon: Icon(
                _saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              ),
              tooltip:
                  _saved ? l10n.diagnosisSaved : l10n.diagnosisSavePrediction,
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final imageHeight =
                      (constraints.maxWidth * 0.58)
                          .clamp(180.0, 280.0)
                          .toDouble();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImage(imageHeight),
                      const SizedBox(height: 20),
                      Text(
                        widget.prediction.displayName,
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        plant == null
                            ? l10n.diagnosisAiPrediction
                            : '${plant.name} • ${plant.species}',
                        style: const TextStyle(
                          color: PlantPulseColors.muted,
                          fontSize: 12,
                        ),
                      ),
                      _buildSaveStatus(l10n),
                      const SizedBox(height: 20),
                      _buildConfidenceCard(confidencePercent, l10n),
                      const SizedBox(height: 22),
                      Text(
                        l10n.diagnosisDetails,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        _isHealthy
                            ? l10n.diagnosisHealthyDescription
                            : l10n.diagnosisDiseaseDescription(
                              widget.prediction.displayName,
                            ),
                        style: const TextStyle(height: 1.6, fontSize: 14),
                      ),
                      const SizedBox(height: 18),
                      _buildNotice(l10n),
                      const SizedBox(height: 22),
                      _buildActionButtons(l10n),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
