import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../shared/widgets/plantpulse_scaffold.dart';
import '../diagnosis/diagnosis_screen.dart';

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
            PageHeader(
              title: 'Scan History',
              subtitle: 'Your recent and earlier inspections',
              trailing: IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.ios_share_rounded),
              ),
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                StatusPill(
                  text: 'All',
                  background: PlantPulseColors.mint,
                  foreground: PlantPulseColors.green,
                ),
                SizedBox(width: 8),
                StatusPill(
                  text: 'Healthy',
                  background: Colors.white,
                  foreground: PlantPulseColors.muted,
                ),
                SizedBox(width: 8),
                StatusPill(
                  text: 'Disease',
                  background: Colors.white,
                  foreground: PlantPulseColors.muted,
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Today', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            _HistoryCard(
              plant: 'Tomato Roma',
              result: 'Early Blight',
              confidence: '92%',
              danger: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DiagnosisScreen()),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Earlier', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const _HistoryCard(
              plant: 'Potato',
              result: 'Healthy',
              confidence: '96%',
            ),
            const SizedBox(height: 10),
            const _HistoryCard(
              plant: 'Green Pepper',
              result: 'Healthy',
              confidence: '94%',
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.file_download_outlined),
              label: const Text('Export inspection report'),
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
  final VoidCallback? onTap;

  const _HistoryCard({
    required this.plant,
    required this.result,
    required this.confidence,
    this.danger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const PlantIcon(),
        title: Text(plant, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(result),
        trailing: StatusPill(
          text: confidence,
          background: danger ? PlantPulseColors.dangerBg : PlantPulseColors.successBg,
          foreground: danger ? PlantPulseColors.danger : PlantPulseColors.green,
        ),
      ),
    );
  }
}
