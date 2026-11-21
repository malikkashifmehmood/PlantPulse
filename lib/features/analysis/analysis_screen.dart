import 'dart:io';

import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_theme.dart';
import '../../core/models/plant.dart';
import '../../l10n/app_localizations.dart';
import '../diagnosis/diagnosis_screen.dart';
import '../scan/low_confidence_screen.dart';
import 'view_models/prediction_view_model.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key, required this.imageFile, this.plant});

  final Plant? plant;
  final File imageFile;

  static const double confidenceThreshold = 0.80;

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  late PredictionViewModel _viewModel;

  bool _initialized = false;
  bool _navigated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    _viewModel = PredictionViewModel(AppServicesScope.of(context).predictions);

    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _runPrediction();
      }
    });
  }

  Future<void> _runPrediction() async {
    if (!mounted || _navigated) return;

    await _viewModel.predict(widget.imageFile);

    if (!mounted) return;

    final prediction = _viewModel.prediction;

    if (prediction == null) return;

    _navigated = true;

    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    final Widget destination;

    if (prediction.confidence < AnalysisScreen.confidenceThreshold) {
      destination = LowConfidenceScreen(
        imageFile: widget.imageFile,
        prediction: prediction,
        plant: widget.plant,
      );
    } else {
      destination = DiagnosisScreen(
        plant: widget.plant,
        prediction: prediction,
        imageFile: widget.imageFile,
      );
    }

    if (!mounted) return;

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (_) => destination),
    );
  }

  // Display only: turns raw model labels such as "Tomato___Late_blight"
  // into "Tomato - Late blight". The underlying value is never changed.
  String _readableLabel(String raw) {
    return raw
        .replaceAll('___', ' - ')
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  void dispose() {
    if (_initialized) {
      _viewModel.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final loading = _viewModel.isLoading;
        final error = _viewModel.errorMessage;
        final prediction = _viewModel.prediction;

        final title =
            error != null
                ? l10n.analysisCouldNotFinish
                : loading
                ? l10n.analyzingYourLeaf
                : l10n.analysisComplete;

        final description =
            error != null
                ? l10n.analysisImageFailedDescription
                : loading
                ? l10n.analysisProcessingDescription
                : l10n.analysisSuccessDescription;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: l10n.closeAnalysis,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
            ),
            title: Text(l10n.analysisTitle),
          ),
          body: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final imageSize = (constraints.maxWidth * 0.48).clamp(
                  120.0,
                  190.0,
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 48,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: PlantPulseColors.bright.withValues(
                                  alpha: .5,
                                ),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: PlantPulseColors.green.withValues(
                                    alpha: .18,
                                  ),
                                  blurRadius: 28,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: Image.file(
                              widget.imageFile,
                              width: imageSize,
                              height: imageSize,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return Container(
                                  width: imageSize,
                                  height: imageSize,
                                  color: Theme.of(context).colorScheme.surface,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                    size: 56,
                                    color: PlantPulseColors.muted,
                                  ),
                                );
                              },
                            ),
                          ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.4,
                              color: PlantPulseColors.forest,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: PlantPulseColors.muted,
                              height: 1.5,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 28),
                          if (loading)
                            const SizedBox(
                              width: 42,
                              height: 42,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: PlantPulseColors.green,
                              ),
                            )
                          else if (error != null)
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Colors.red,
                              size: 48,
                            )
                          else
                            const Icon(
                              Icons.check_circle_rounded,
                              color: PlantPulseColors.green,
                              size: 48,
                            ),
                          if (loading) ...[
                            const SizedBox(height: 24),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: const LinearProgressIndicator(
                                minHeight: 6,
                                color: PlantPulseColors.bright,
                                backgroundColor: PlantPulseColors.mint,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.keepAppOpen,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: PlantPulseColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (error != null) ...[
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                error,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _runPrediction,
                                icon: const Icon(Icons.refresh_rounded),
                                label: Text(l10n.tryAgain),
                              ),
                            ),
                          ],
                          if (prediction != null && !loading) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: PlantPulseColors.mint,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _readableLabel(prediction.displayName),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: PlantPulseColors.forest,
                                ),
                              ),
                            ),
                          ],
                          if (!loading) ...[
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(l10n.backToScan),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
