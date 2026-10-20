import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/network/plantpulse_api.dart';

class TreatmentScreen extends StatefulWidget {
  const TreatmentScreen({
    super.key,
    this.prediction,
    this.plantName,
    this.species,
  });

  final PlantPulsePrediction? prediction;
  final String? plantName;
  final String? species;

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
  bool _planStarted = false;

  static const _generalSteps = <_TreatmentStep>[
    _TreatmentStep(
      'Today',
      'Inspect the leaf and photograph visible symptoms',
      Icons.search_rounded,
    ),
    _TreatmentStep(
      'Today',
      'Keep tools clean and avoid handling wet foliage',
      Icons.cleaning_services_outlined,
    ),
    _TreatmentStep(
      'Day 3',
      'Recheck the plant for changes in symptoms',
      Icons.visibility_outlined,
    ),
    _TreatmentStep(
      'Day 7',
      'Take a new scan and compare the results',
      Icons.center_focus_strong_rounded,
    ),
  ];

  static const _plans = <String, _TreatmentPlan>{
    'Tomato___Bacterial_spot': _TreatmentPlan(
      title: 'Bacterial Spot',
      description:
          'Reduce leaf wetness and limit the spread of suspected infection.',
      steps: [
        _TreatmentStep(
          'Today',
          'Avoid overhead watering and wet foliage',
          Icons.water_drop_outlined,
        ),
        _TreatmentStep(
          'Today',
          'Clean tools before using them on another plant',
          Icons.cleaning_services_outlined,
        ),
        _TreatmentStep(
          'Day 3',
          'Inspect new growth for spreading spots',
          Icons.search_rounded,
        ),
        _TreatmentStep(
          'Day 7',
          'Seek local agricultural advice if symptoms spread',
          Icons.support_agent_rounded,
        ),
      ],
    ),
    'Tomato___Early_blight': _TreatmentPlan(
      title: 'Early Blight',
      description: 'Improve growing conditions and monitor affected foliage.',
      steps: [
        _TreatmentStep(
          'Today',
          'Inspect lower leaves for spreading lesions',
          Icons.search_rounded,
        ),
        _TreatmentStep(
          'Today',
          'Improve airflow and avoid wetting the leaves',
          Icons.air_rounded,
        ),
        _TreatmentStep(
          'Day 3',
          'Remove severely affected leaves if appropriate',
          Icons.content_cut_rounded,
        ),
        _TreatmentStep(
          'Day 7',
          'Rescan the plant and compare symptoms',
          Icons.center_focus_strong_rounded,
        ),
      ],
    ),
    'Tomato___Late_blight': _TreatmentPlan(
      title: 'Late Blight',
      description:
          'Act promptly if symptoms are consistent with late blight, '
          'which can spread rapidly in favorable conditions.',
      steps: [
        _TreatmentStep(
          'Today',
          'Separate the affected plant where practical',
          Icons.spa_outlined,
        ),
        _TreatmentStep(
          'Today',
          'Avoid overhead watering and handling wet leaves',
          Icons.water_drop_outlined,
        ),
        _TreatmentStep(
          'Promptly',
          'Contact a local agricultural extension specialist',
          Icons.support_agent_rounded,
        ),
        _TreatmentStep(
          'Follow-up',
          'Check nearby tomato plants for similar symptoms',
          Icons.search_rounded,
        ),
      ],
    ),
    'Tomato___Leaf_Mold': _TreatmentPlan(
      title: 'Leaf Mold',
      description:
          'Leaf mold is often favored by humid conditions and poor airflow.',
      steps: [
        _TreatmentStep(
          'Today',
          'Improve ventilation around the foliage',
          Icons.air_rounded,
        ),
        _TreatmentStep(
          'Today',
          'Water near the soil rather than over the leaves',
          Icons.water_drop_outlined,
        ),
        _TreatmentStep(
          'Day 3',
          'Check leaf undersides for additional symptoms',
          Icons.search_rounded,
        ),
        _TreatmentStep(
          'Day 7',
          'Recheck the plant and review humidity conditions',
          Icons.center_focus_strong_rounded,
        ),
      ],
    ),
    'Tomato___Septoria_leaf_spot': _TreatmentPlan(
      title: 'Septoria Leaf Spot',
      description: 'Reduce splash dispersal and monitor the lower foliage.',
      steps: [
        _TreatmentStep(
          'Today',
          'Avoid splashing soil or water onto the leaves',
          Icons.water_drop_outlined,
        ),
        _TreatmentStep(
          'Today',
          'Remove severely affected lower leaves if appropriate',
          Icons.content_cut_rounded,
        ),
        _TreatmentStep(
          'Day 3',
          'Inspect nearby leaves for new spots',
          Icons.search_rounded,
        ),
        _TreatmentStep(
          'Day 7',
          'Rescan and review symptom progression',
          Icons.center_focus_strong_rounded,
        ),
      ],
    ),
    'Tomato___Spider_mites Two-spotted_spider_mite': _TreatmentPlan(
      title: 'Spider Mites',
      description:
          'Look for fine webbing and tiny mites before choosing a treatment.',
      steps: [
        _TreatmentStep(
          'Today',
          'Inspect leaf undersides for mites and fine webbing',
          Icons.search_rounded,
        ),
        _TreatmentStep(
          'Today',
          'Check neighboring plants for similar damage',
          Icons.spa_outlined,
        ),
        _TreatmentStep(
          'Day 3',
          'Reinspect affected leaves for active mites',
          Icons.visibility_outlined,
        ),
        _TreatmentStep(
          'Day 7',
          'Seek locally appropriate pest-control advice if needed',
          Icons.support_agent_rounded,
        ),
      ],
    ),
    'Tomato___Target_Spot': _TreatmentPlan(
      title: 'Target Spot',
      description: 'Monitor leaf lesions and reduce prolonged leaf wetness.',
      steps: [
        _TreatmentStep(
          'Today',
          'Inspect leaves for circular or target-like lesions',
          Icons.search_rounded,
        ),
        _TreatmentStep(
          'Today',
          'Improve airflow and avoid overhead irrigation',
          Icons.air_rounded,
        ),
        _TreatmentStep(
          'Day 3',
          'Check whether lesions are appearing on new leaves',
          Icons.visibility_outlined,
        ),
        _TreatmentStep(
          'Day 7',
          'Seek expert advice if the symptoms continue to spread',
          Icons.support_agent_rounded,
        ),
      ],
    ),
    'Tomato___Tomato_Yellow_Leaf_Curl_Virus': _TreatmentPlan(
      title: 'Yellow Leaf Curl Virus',
      description:
          'Suspected viral disease requires careful inspection and '
          'management of possible whitefly vectors.',
      steps: [
        _TreatmentStep(
          'Today',
          'Inspect leaves for curling, yellowing and stunted growth',
          Icons.search_rounded,
        ),
        _TreatmentStep(
          'Today',
          'Check the undersides of leaves for whiteflies',
          Icons.visibility_outlined,
        ),
        _TreatmentStep(
          'Day 3',
          'Monitor nearby plants for similar symptoms',
          Icons.spa_outlined,
        ),
        _TreatmentStep(
          'Promptly',
          'Ask an agricultural specialist about confirmation and control',
          Icons.support_agent_rounded,
        ),
      ],
    ),
    'Tomato___Tomato_mosaic_virus': _TreatmentPlan(
      title: 'Tomato Mosaic Virus',
      description:
          'There is no curative treatment for an established viral '
          'infection. Confirm the diagnosis before removing a plant.',
      steps: [
        _TreatmentStep(
          'Today',
          'Clean hands and tools after handling the suspect plant',
          Icons.cleaning_services_outlined,
        ),
        _TreatmentStep(
          'Today',
          'Avoid transferring sap between tomato plants',
          Icons.shield_outlined,
        ),
        _TreatmentStep(
          'Day 3',
          'Inspect nearby plants for mosaic patterns or distortion',
          Icons.search_rounded,
        ),
        _TreatmentStep(
          'Promptly',
          'Seek expert confirmation and locally appropriate guidance',
          Icons.support_agent_rounded,
        ),
      ],
    ),
    'Tomato___healthy': _TreatmentPlan(
      title: 'Healthy Tomato Leaf',
      description:
          'The model classified the image as healthy. Continue routine care '
          'and monitor the plant for changes.',
      isHealthy: true,
      steps: [
        _TreatmentStep(
          'Today',
          'Check the plant for visible changes or pests',
          Icons.search_rounded,
        ),
        _TreatmentStep(
          'Daily',
          'Water according to the plant and soil needs',
          Icons.water_drop_outlined,
        ),
        _TreatmentStep(
          'Weekly',
          'Inspect new growth and the undersides of leaves',
          Icons.visibility_outlined,
        ),
        _TreatmentStep(
          'As needed',
          'Repeat the scan if symptoms appear',
          Icons.center_focus_strong_rounded,
        ),
      ],
    ),
  };

  _TreatmentPlan get _plan {
    final predictedClass = widget.prediction?.predictedClass;

    if (predictedClass == null) {
      return _TreatmentPlan(
        title: 'General Plant Care',
        description:
            'No AI prediction was supplied. Follow these general '
            'inspection steps rather than disease-specific treatment.',
        steps: _generalSteps,
        isSupported: false,
      );
    }

    return _plans[predictedClass] ??
        _TreatmentPlan(
          title: widget.prediction!.displayName,
          description:
              'A specific care plan is not available for this model label. '
              'Confirm the result before applying a treatment.',
          steps: _generalSteps,
          isSupported: false,
        );
  }

  void _toggleStep(int index) {
    setState(() {
      if (!_completed.add(index)) {
        _completed.remove(index);
      }
    });
  }

  void _startPlan() {
    setState(() => _planStarted = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Treatment checklist started. Track each step here.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    final actions = plan.steps;
    final progress = actions.isEmpty ? 0.0 : _completed.length / actions.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Treatment Plan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
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
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: PlantPulseColors.warning,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'This plan is general guidance based on an AI label, '
                      'not a confirmed diagnosis. Verify symptoms before '
                      'using pesticides or removing a plant.',
                      style: TextStyle(fontSize: 12, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Plan progress',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(100),
            ),
            const SizedBox(height: 8),
            Text(
              '${_completed.length} of ${actions.length} steps completed',
              style: const TextStyle(
                color: PlantPulseColors.muted,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(actions.length, (index) {
              final action = actions[index];
              final done = _completed.contains(index);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => _toggleStep(index),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                onPressed: _planStarted ? null : _startPlan,
                icon: Icon(
                  _planStarted
                      ? Icons.check_circle_rounded
                      : Icons.play_arrow_rounded,
                ),
                label: Text(_planStarted ? 'Plan started' : 'Start plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
