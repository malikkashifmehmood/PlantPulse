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
import '../scan/scan_screen.dart';

class LowConfidenceScreen extends StatefulWidget {
  const LowConfidenceScreen({
    super.key,
    required this.imageFile,
    required this.prediction,
    this.plant,
    this.auth,
  });

  final File imageFile;
  final PlantPulsePrediction prediction;
  final Plant? plant;
  final FirebaseAuth? auth;

  @override
  State<LowConfidenceScreen> createState() => _LowConfidenceScreenState();
}

class _LowConfidenceScreenState extends State<LowConfidenceScreen> {
  bool _saving = false;
  bool _saved = false;
  bool _saveAttempted = false;

  FirebaseAuth? get _auth {
    if (widget.auth != null) return widget.auth;
    if (Firebase.apps.isEmpty) return null;
    return FirebaseAuth.instance;
  }

  String get _scope => _auth?.currentUser?.uid ?? 'guest';

  double get _confidence =>
      widget.prediction.confidence.clamp(0.0, 1.0).toDouble();

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
        SnackBar(
          content: Text(
            AppLocalizations.of(context).lowConfidenceSavedForPlant(plant.name),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saveAttempted = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).lowConfidenceSaveFailed),
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

  Widget _buildSaveStatus(AppLocalizations l10n) {
    if (widget.plant == null) {
      return const SizedBox.shrink();
    }

    final String message;

    if (_saved) {
      message = l10n.lowConfidenceSavedHistory;
    } else if (_saving) {
      message = l10n.lowConfidenceSaving;
    } else {
      message = l10n.lowConfidenceCanSaveHistory;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: PlantPulseColors.muted, fontSize: 12),
          ),
          if (!_saved && !_saving) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _saveDiagnosis,
              icon: const Icon(Icons.bookmark_border_rounded),
              label: Text(l10n.savePrediction),
            ),
          ],
        ],
      ),
    );
  }

  void _retakePhoto() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (_) => ScanScreen(plant: widget.plant)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final confidencePercent = (_confidence * 100).round();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.closeResult,
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(l10n.scanResult),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.file(
                      widget.imageFile,
                      height: 190,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            height: 190,
                            color: PlantPulseColors.mint,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              size: 64,
                              color: PlantPulseColors.muted,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: PlantPulseColors.warning,
                    size: 42,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.lowConfidenceTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.lowConfidenceDescription,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: PlantPulseColors.muted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.modelPrediction,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.prediction.displayName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.modelScore,
                                style: const TextStyle(
                                  color: PlantPulseColors.muted,
                                ),
                              ),
                              Text(
                                '$confidencePercent%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _confidence,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(100),
                            color: PlantPulseColors.warning,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.modelNameLabel(widget.prediction.model),
                            style: const TextStyle(
                              color: PlantPulseColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.plant != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      l10n.plantLabel(widget.plant!.name),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    _buildSaveStatus(l10n),
                  ],
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.photoTipsTitle,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 8),
                          _Tip(
                            icon: Icons.wb_sunny_outlined,
                            text: l10n.useBetterLighting,
                          ),
                          _Tip(
                            icon: Icons.crop_free_rounded,
                            text: l10n.keepLeafInFrame,
                          ),
                          _Tip(
                            icon: Icons.pan_tool_alt_outlined,
                            text: l10n.holdPhoneSteady,
                          ),
                          _Tip(
                            icon: Icons.center_focus_strong_rounded,
                            text: l10n.focusAffectedArea,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: _retakePhoto,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.retakePhoto),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const ExpertScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.support_agent_rounded),
                    label: Text(l10n.askExpert),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: PlantPulseColors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
