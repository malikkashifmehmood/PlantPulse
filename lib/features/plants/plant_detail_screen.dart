import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../shared/widgets/plantpulse_scaffold.dart';
import '../scan/scan_screen.dart';

class PlantDetailScreen extends StatelessWidget {
  const PlantDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Plant Detail'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  colors: [Color(0xFF274B2F), Color(0xFF75A861)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(Icons.eco_rounded, color: Colors.white, size: 82),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Tomato Roma',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                ),
                StatusPill(
                  text: 'Attention',
                  background: PlantPulseColors.warningBg,
                  foreground: PlantPulseColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _InfoCard(
              title: 'Current status',
              value: 'Possible Early Blight',
              icon: Icons.health_and_safety_outlined,
            ),
            const SizedBox(height: 10),
            const _InfoCard(
              title: 'Active care plan',
              value: '3 steps remaining',
              icon: Icons.assignment_turned_in_outlined,
            ),
            const SizedBox(height: 22),
            const Text(
              'Scan timeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            const _Timeline(
              date: 'Today',
              title: 'Early Blight',
              detail: '92% confidence',
              danger: true,
            ),
            const _Timeline(
              date: 'Sep 30',
              title: 'Healthy',
              detail: '96% confidence',
            ),
            const _Timeline(
              date: 'Sep 25',
              title: 'Healthy',
              detail: '94% confidence',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScanScreen()),
                  ),
              icon: const Icon(Icons.center_focus_strong_rounded),
              label: const Text('Scan Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: PlantPulseColors.green),
        title: Text(
          title,
          style: const TextStyle(color: PlantPulseColors.muted, fontSize: 11),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final String date;
  final String title;
  final String detail;
  final bool danger;

  const _Timeline({
    required this.date,
    required this.title,
    required this.detail,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              date,
              style: const TextStyle(
                color: PlantPulseColors.muted,
                fontSize: 10,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color:
                      danger ? PlantPulseColors.danger : PlantPulseColors.green,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Container(width: 2, color: PlantPulseColors.line),
              ),
            ],
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                child: ListTile(
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(detail),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
