import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../shared/widgets/plantpulse_scaffold.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlantPulseScaffold(
      currentIndex: 0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Scan History',
              subtitle: 'Your recent and earlier inspections',
            ),
            const SizedBox(height: 24),
            const Text('Today', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const _HistoryCard(
              plant: 'Tomato Roma',
              result: 'Early Blight',
              confidence: '92%',
              danger: true,
            ),
            const SizedBox(height: 10),
            const _HistoryCard(
              plant: 'Garden Tomato',
              result: 'Healthy',
              confidence: '96%',
              danger: false,
            ),
            const SizedBox(height: 22),
            const Text(
              'Earlier',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const _HistoryCard(
              plant: 'Tomato Plant',
              result: 'Late Blight',
              confidence: '89%',
              danger: true,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PlantPulseColors.cream,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'These are sample history entries. Live scan history '
                'will appear when saved diagnosis records are connected.',
                style: TextStyle(height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String plant;
  final String result;
  final String confidence;
  final bool danger;

  const _HistoryCard({
    required this.plant,
    required this.result,
    required this.confidence,
    required this.danger,
  });

  @override
  Widget build(BuildContext context) {
    final resultColor =
        danger ? PlantPulseColors.danger : PlantPulseColors.green;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor:
              danger ? PlantPulseColors.dangerBg : PlantPulseColors.successBg,
          child: Icon(
            danger ? Icons.warning_amber_rounded : Icons.eco_rounded,
            color: resultColor,
          ),
        ),
        title: Text(plant, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(result),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              confidence,
              style: TextStyle(fontWeight: FontWeight.w900, color: resultColor),
            ),
            const SizedBox(height: 4),
            const Text('Model score', style: TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
