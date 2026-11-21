import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_theme.dart';
import '../../core/network/plantpulse_api.dart';
import '../../l10n/app_localizations.dart';
import 'models/treatment_progress.dart';

class TreatmentScreen extends StatefulWidget {
  const TreatmentScreen({
    super.key,
    this.prediction,
    this.plantName,
    this.species,
    this.plantId,
    this.userScope,
  });

  final PlantPulsePrediction? prediction;
  final String? plantName;
  final String? species;
  final String? plantId;
  final String? userScope;

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentStep {
  const _TreatmentStep(this.day, this.title, this.icon);

  final String day;
  final String title;
  final IconData icon;
}

class _TreatmentPlan {
  const _TreatmentPlan({
    required this.title,
    required this.description,
    required this.steps,
    this.isHealthy = false,
    this.isSupported = true,
  });

  final String title;
  final String description;
  final List<_TreatmentStep> steps;
  final bool isHealthy;
  final bool isSupported;
}

class _TreatmentScreenState extends State<TreatmentScreen> {
  final Set<int> _completed = <int>{};

  Future<void> _saveQueue = Future<void>.value();

  bool _planStarted = false;
  bool _isLoadingProgress = true;
  bool _hasUserChanges = false;

  String get _scope {
    final suppliedScope = widget.userScope?.trim();

    return suppliedScope == null || suppliedScope.isEmpty
        ? 'guest'
        : suppliedScope;
  }

  String get _contextId {
    final plantId = widget.plantId?.trim();

    if (plantId == null || plantId.isEmpty) {
      return '';
    }

    return '$plantId:${widget.prediction?.predictedClass ?? 'general'}';
  }

  bool get _canPersist => _contextId.isNotEmpty;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadProgress();
      }
    });
  }

  Future<void> _loadProgress() async {
    if (!_canPersist) {
      if (mounted) {
        setState(() => _isLoadingProgress = false);
      }
      return;
    }

    try {
      final repository = AppServicesScope.of(context).treatmentProgress;

      final saved = repository.loadProgress(
        scope: _scope,
        contextId: _contextId,
      );

      if (!mounted) return;

      if (!_hasUserChanges) {
        // Build the current plan to validate saved step indexes.
        final stepCount = _buildPlan(AppLocalizations.of(context)).steps.length;

        setState(() {
          _planStarted = saved?.planStarted ?? false;

          _completed
            ..clear()
            ..addAll(
              (saved?.completedSteps ?? const <int>{}).where(
                (index) => index >= 0 && index < stepCount,
              ),
            );
        });
      }
    } catch (_) {
      // Keep the treatment screen usable if local persistence fails.
    } finally {
      if (mounted) {
        setState(() => _isLoadingProgress = false);
      }
    }
  }

  Future<void> _persistProgress() {
    if (!_canPersist) {
      return Future<void>.value();
    }

    final repository = AppServicesScope.of(context).treatmentProgress;

    final progress = TreatmentProgress(
      planStarted: _planStarted,
      completedSteps: Set<int>.unmodifiable(_completed),
      updatedAt: DateTime.now(),
    );

    _saveQueue = _saveQueue
        .catchError((Object _) {
          // Allow later saves to continue after an earlier failure.
        })
        .then((_) {
          return repository.saveProgress(
            scope: _scope,
            contextId: _contextId,
            progress: progress,
          );
        })
        .catchError((Object _) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).treatmentSaveFailed),
            ),
          );
        });

    return _saveQueue;
  }

  _TreatmentStep _step(String day, String title, IconData icon) {
    return _TreatmentStep(day, title, icon);
  }

  _TreatmentPlan _buildPlan(AppLocalizations l10n) {
    final predictedClass = widget.prediction?.predictedClass;

    final generalSteps = <_TreatmentStep>[
      _step(
        l10n.treatmentToday,
        l10n.treatmentGeneralStep1,
        Icons.search_rounded,
      ),
      _step(
        l10n.treatmentToday,
        l10n.treatmentGeneralStep2,
        Icons.cleaning_services_outlined,
      ),
      _step(
        l10n.treatmentDay3,
        l10n.treatmentGeneralStep3,
        Icons.visibility_outlined,
      ),
      _step(
        l10n.treatmentDay7,
        l10n.treatmentGeneralStep4,
        Icons.center_focus_strong_rounded,
      ),
    ];

    if (predictedClass == null) {
      return _TreatmentPlan(
        title: l10n.treatmentGeneralTitle,
        description: l10n.treatmentGeneralDescription,
        steps: generalSteps,
        isSupported: false,
      );
    }

    switch (predictedClass) {
      case 'Tomato___Bacterial_spot':
        return _TreatmentPlan(
          title: l10n.treatmentBacterialSpotTitle,
          description: l10n.treatmentBacterialSpotDescription,
          steps: [
            _step(
              l10n.treatmentToday,
              l10n.treatmentBacterialSpotStep1,
              Icons.water_drop_outlined,
            ),
            _step(
              l10n.treatmentToday,
              l10n.treatmentBacterialSpotStep2,
              Icons.cleaning_services_outlined,
            ),
            _step(
              l10n.treatmentDay3,
              l10n.treatmentBacterialSpotStep3,
              Icons.search_rounded,
            ),
            _step(
              l10n.treatmentDay7,
              l10n.treatmentBacterialSpotStep4,
              Icons.support_agent_rounded,
            ),
          ],
        );

      case 'Tomato___Early_blight':
        return _TreatmentPlan(
          title: l10n.treatmentEarlyBlightTitle,
          description: l10n.treatmentEarlyBlightDescription,
          steps: [
            _step(
              l10n.treatmentToday,
              l10n.treatmentEarlyBlightStep1,
              Icons.search_rounded,
            ),
            _step(
              l10n.treatmentToday,
              l10n.treatmentEarlyBlightStep2,
              Icons.air_rounded,
            ),
            _step(
              l10n.treatmentDay3,
              l10n.treatmentEarlyBlightStep3,
              Icons.content_cut_rounded,
            ),
            _step(
              l10n.treatmentDay7,
              l10n.treatmentEarlyBlightStep4,
              Icons.center_focus_strong_rounded,
            ),
          ],
        );

      case 'Tomato___Late_blight':
        return _TreatmentPlan(
          title: l10n.treatmentLateBlightTitle,
          description: l10n.treatmentLateBlightDescription,
          steps: [
            _step(
              l10n.treatmentToday,
              l10n.treatmentLateBlightStep1,
              Icons.spa_outlined,
            ),
            _step(
              l10n.treatmentToday,
              l10n.treatmentLateBlightStep2,
              Icons.water_drop_outlined,
            ),
            _step(
              l10n.treatmentPromptly,
              l10n.treatmentLateBlightStep3,
              Icons.support_agent_rounded,
            ),
            _step(
              l10n.treatmentFollowUp,
              l10n.treatmentLateBlightStep4,
              Icons.search_rounded,
            ),
          ],
        );

      case 'Tomato___Leaf_Mold':
        return _TreatmentPlan(
          title: l10n.treatmentLeafMoldTitle,
          description: l10n.treatmentLeafMoldDescription,
          steps: [
            _step(
              l10n.treatmentToday,
              l10n.treatmentLeafMoldStep1,
              Icons.air_rounded,
            ),
            _step(
              l10n.treatmentToday,
              l10n.treatmentLeafMoldStep2,
              Icons.water_drop_outlined,
            ),
            _step(
              l10n.treatmentDay3,
              l10n.treatmentLeafMoldStep3,
              Icons.search_rounded,
            ),
            _step(
              l10n.treatmentDay7,
              l10n.treatmentLeafMoldStep4,
              Icons.center_focus_strong_rounded,
            ),
          ],
        );

      case 'Tomato___Septoria_leaf_spot':
        return _TreatmentPlan(
          title: l10n.treatmentSeptoriaTitle,
          description: l10n.treatmentSeptoriaDescription,
          steps: [
            _step(
              l10n.treatmentToday,
              l10n.treatmentSeptoriaStep1,
              Icons.water_drop_outlined,
            ),
            _step(
              l10n.treatmentToday,
              l10n.treatmentSeptoriaStep2,
              Icons.content_cut_rounded,
            ),
            _step(
              l10n.treatmentDay3,
              l10n.treatmentSeptoriaStep3,
              Icons.search_rounded,
            ),
            _step(
              l10n.treatmentDay7,
              l10n.treatmentSeptoriaStep4,
              Icons.center_focus_strong_rounded,
            ),
          ],
        );

      case 'Tomato___Spider_mites Two-spotted_spider_mite':
        return _TreatmentPlan(
          title: l10n.treatmentSpiderMitesTitle,
          description: l10n.treatmentSpiderMitesDescription,
          steps: [
            _step(
              l10n.treatmentToday,
              l10n.treatmentSpiderMitesStep1,
              Icons.search_rounded,
            ),
            _step(
              l10n.treatmentToday,
              l10n.treatmentSpiderMitesStep2,
              Icons.spa_outlined,
            ),
            _step(
              l10n.treatmentDay3,
              l10n.treatmentSpiderMitesStep3,
              Icons.visibility_outlined,
            ),
            _step(
              l10n.treatmentDay7,
              l10n.treatmentSpiderMitesStep4,
              Icons.support_agent_rounded,
            ),
          ],
        );

      case 'Tomato___Target_Spot':
        return _TreatmentPlan(
          title: l10n.treatmentTargetSpotTitle,
          description: l10n.treatmentTargetSpotDescription,
          steps: [
            _step(
              l10n.treatmentToday,
              l10n.treatmentTargetSpotStep1,
              Icons.search_rounded,
            ),
            _step(
              l10n.treatmentToday,
              l10n.treatmentTargetSpotStep2,
              Icons.air_rounded,
            ),
            _step(
              l10n.treatmentDay3,
              l10n.treatmentTargetSpotStep3,
              Icons.visibility_outlined,
            ),
            _step(
              l10n.treatmentDay7,
              l10n.treatmentTargetSpotStep4,
              Icons.support_agent_rounded,
            ),
          ],
        );

      case 'Tomato___Tomato_Yellow_Leaf_Curl_Virus':
        return _TreatmentPlan(
          title: l10n.treatmentYellowLeafCurlTitle,
          description: l10n.treatmentYellowLeafCurlDescription,
          steps: [
            _step(
              l10n.treatmentToday,
              l10n.treatmentYellowLeafCurlStep1,
              Icons.search_rounded,
            ),
            _step(
              l10n.treatmentToday,
              l10n.treatmentYellowLeafCurlStep2,
              Icons.visibility_outlined,
            ),
            _step(
              l10n.treatmentDay3,
              l10n.treatmentYellowLeafCurlStep3,
              Icons.spa_outlined,
            ),
            _step(
              l10n.treatmentPromptly,
              l10n.treatmentYellowLeafCurlStep4,
              Icons.support_agent_rounded,
            ),
          ],
        );

      case 'Tomato___Tomato_mosaic_virus':
        return _TreatmentPlan(
          title: l10n.treatmentMosaicVirusTitle,
          description: l10n.treatmentMosaicVirusDescription,
          steps: [
            _step(
              l10n.treatmentToday,
              l10n.treatmentMosaicVirusStep1,
              Icons.cleaning_services_outlined,
            ),
            _step(
              l10n.treatmentToday,
              l10n.treatmentMosaicVirusStep2,
              Icons.shield_outlined,
            ),
            _step(
              l10n.treatmentDay3,
              l10n.treatmentMosaicVirusStep3,
              Icons.search_rounded,
            ),
            _step(
              l10n.treatmentPromptly,
              l10n.treatmentMosaicVirusStep4,
              Icons.support_agent_rounded,
            ),
          ],
        );

      case 'Tomato___healthy':
        return _TreatmentPlan(
          title: l10n.treatmentHealthyTitle,
          description: l10n.treatmentHealthyDescription,
          isHealthy: true,
          steps: [
            _step(
              l10n.treatmentToday,
              l10n.treatmentHealthyStep1,
              Icons.search_rounded,
            ),
            _step(
              l10n.treatmentDaily,
              l10n.treatmentHealthyStep2,
              Icons.water_drop_outlined,
            ),
            _step(
              l10n.treatmentWeekly,
              l10n.treatmentHealthyStep3,
              Icons.visibility_outlined,
            ),
            _step(
              l10n.treatmentAsNeeded,
              l10n.treatmentHealthyStep4,
              Icons.center_focus_strong_rounded,
            ),
          ],
        );

      default:
        return _TreatmentPlan(
          title: widget.prediction!.displayName,
          description: l10n.treatmentUnsupportedDescription,
          steps: generalSteps,
          isSupported: false,
        );
    }
  }

  void _toggleStep(int index) {
    if (_isLoadingProgress) return;

    setState(() {
      _hasUserChanges = true;

      if (!_completed.add(index)) {
        _completed.remove(index);
      }
    });

    _persistProgress();
  }

  void _startPlan() {
    if (_isLoadingProgress || _planStarted) return;

    setState(() {
      _hasUserChanges = true;
      _planStarted = true;
    });

    _persistProgress();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).treatmentPlanStartedMessage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plan = _buildPlan(l10n);
    final actions = plan.steps;
    final progress = actions.isEmpty ? 0.0 : _completed.length / actions.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(l10n.treatmentTitle),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth =
              constraints.maxWidth > 760 ? 720.0 : constraints.maxWidth;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: Center(
              child: SizedBox(
                width: contentWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: PlantPulseColors.mint,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            plan.isHealthy
                                ? Icons.check_circle_outline_rounded
                                : Icons.eco_rounded,
                            color: PlantPulseColors.green,
                            size: 38,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.title,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                if (widget.plantName != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.plantName!,
                                    style: const TextStyle(
                                      color: PlantPulseColors.muted,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                                if (widget.species != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.species!,
                                    style: const TextStyle(
                                      color: PlantPulseColors.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Text(
                                  plan.description,
                                  style: const TextStyle(height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: PlantPulseColors.warningBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: PlantPulseColors.warning,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              l10n.treatmentSafetyNotice,
                              style: const TextStyle(fontSize: 12, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!plan.isSupported) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: PlantPulseColors.mint,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: PlantPulseColors.green,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                l10n.treatmentGeneralNotice,
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    Text(
                      l10n.treatmentProgress,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    if (!_canPersist) ...[
                      const SizedBox(height: 5),
                      Text(
                        l10n.treatmentSessionOnly,
                        style: const TextStyle(
                          color: PlantPulseColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.treatmentStepsCompleted(
                        _completed.length,
                        actions.length,
                      ),
                      style: const TextStyle(
                        color: PlantPulseColors.muted,
                        fontSize: 11,
                      ),
                    ),
                    if (_isLoadingProgress) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(minHeight: 2),
                    ],
                    const SizedBox(height: 20),
                    ...List.generate(actions.length, (index) {
                      final action = actions[index];
                      final done = _completed.contains(index);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap:
                                _isLoadingProgress
                                    ? null
                                    : () => _toggleStep(index),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                children: [
                                  Icon(
                                    done
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    color:
                                        done
                                            ? PlantPulseColors.green
                                            : PlantPulseColors.line,
                                    size: 26,
                                  ),
                                  const SizedBox(width: 13),
                                  Icon(
                                    action.icon,
                                    color: PlantPulseColors.green,
                                    size: 21,
                                  ),
                                  const SizedBox(width: 11),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          action.day,
                                          style: const TextStyle(
                                            color: PlantPulseColors.green,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          action.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            decoration:
                                                done
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed:
                            _isLoadingProgress || _planStarted
                                ? null
                                : _startPlan,
                        icon: Icon(
                          _planStarted
                              ? Icons.check_circle_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(
                          _planStarted
                              ? l10n.treatmentPlanStarted
                              : l10n.treatmentStartPlan,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
