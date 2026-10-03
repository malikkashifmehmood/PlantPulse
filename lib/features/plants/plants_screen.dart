import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../shared/widgets/plantpulse_scaffold.dart';
import 'plant_detail_screen.dart';

class PlantsScreen extends StatelessWidget {
  const PlantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlantPulseScaffold(
      currentIndex: 1,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        child: Column(
          children: [
            PageHeader(
              title: 'My Plants',
              subtitle: '12 monitored plants',
              trailing: IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded),
              ),
            ),
            const SizedBox(height: 18),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Search plants',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                StatusPill(
                  text: 'All 12',
                  background: PlantPulseColors.mint,
                  foreground: PlantPulseColors.green,
                ),
                SizedBox(width: 8),
                StatusPill(
                  text: 'Healthy 10',
                  background: Colors.white,
                  foreground: PlantPulseColors.muted,
                ),
                SizedBox(width: 8),
                StatusPill(
                  text: 'Attention 2',
                  background: PlantPulseColors.warningBg,
                  foreground: PlantPulseColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _PlantCard(
              name: 'Tomato Roma',
              detail: 'Last scan today',
              status: 'Attention',
              danger: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlantDetailScreen()),
              ),
            ),
            const SizedBox(height: 10),
            const _PlantCard(
              name: 'Green Pepper',
              detail: 'Last scan 2 days ago',
              status: 'Healthy',
            ),
            const SizedBox(height: 10),
            const _PlantCard(
              name: 'Potato',
              detail: 'Last scan yesterday',
              status: 'Healthy',
            ),
            const SizedBox(height: 10),
            const _PlantCard(
              name: 'Cucumber',
              detail: 'Last scan 4 days ago',
              status: 'Healthy',
            ),
          ],
        ),
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final String name;
  final String detail;
  final String status;
  final bool danger;
  final VoidCallback? onTap;

  const _PlantCard({
    required this.name,
    required this.detail,
    required this.status,
    this.danger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const PlantIcon(size: 54),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(detail, style: const TextStyle(color: PlantPulseColors.muted, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusPill(
                    text: status,
                    background: danger ? PlantPulseColors.dangerBg : PlantPulseColors.successBg,
                    foreground: danger ? PlantPulseColors.danger : PlantPulseColors.green,
                  ),
                  if (onTap != null)
                    const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Icon(Icons.chevron_right_rounded, size: 18),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
