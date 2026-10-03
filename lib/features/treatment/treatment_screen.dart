import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class TreatmentScreen extends StatefulWidget {
  const TreatmentScreen({super.key});

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> {
  final completed = <int>{0};

  final actions = const [
    ('Today', 'Remove visibly affected leaves', Icons.content_cut_rounded),
    ('Today', 'Improve airflow around the plant', Icons.air_rounded),
    ('Day 3', 'Follow the recommended care step', Icons.water_drop_outlined),
    ('Day 7', 'Recheck the plant with a new scan', Icons.center_focus_strong_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final progress = completed.length / actions.length;
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
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: PlantPulseColors.mint,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                children: [
                  Icon(Icons.eco_rounded, color: PlantPulseColors.green, size: 38),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Early Blight', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                        SizedBox(height: 3),
                        Text('Tomato Roma', style: TextStyle(color: PlantPulseColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('Plan progress', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(100),
            ),
            const SizedBox(height: 8),
            Text(
              '${completed.length} of ${actions.length} steps completed',
              style: const TextStyle(color: PlantPulseColors.muted, fontSize: 11),
            ),
            const SizedBox(height: 20),
            ...List.generate(actions.length, (i) {
              final action = actions[i];
              final done = completed.contains(i);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {
                      setState(() {
                        if (done) {
                          completed.remove(i);
                        } else {
                          completed.add(i);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          Icon(
                            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            color: done ? PlantPulseColors.green : PlantPulseColors.line,
                            size: 26,
                          ),
                          const SizedBox(width: 13),
                          Icon(action.$3, color: PlantPulseColors.green, size: 21),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  action.$1,
                                  style: const TextStyle(
                                    color: PlantPulseColors.green,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  action.$2,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    decoration: done ? TextDecoration.lineThrough : null,
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
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start plan'),
            ),
          ],
        ),
      ),
    );
  }
}
