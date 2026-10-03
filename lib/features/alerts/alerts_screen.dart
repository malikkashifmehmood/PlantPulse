import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../shared/widgets/plantpulse_scaffold.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlantPulseScaffold(
      currentIndex: 3,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Alerts',
              subtitle: 'Warnings, reminders and rechecks',
            ),
            const SizedBox(height: 20),
            const Text('Today', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            const _Alert(
              title: 'High risk',
              subtitle: 'Tomato Roma may need attention',
              time: '10 min ago',
              icon: Icons.warning_amber_rounded,
              color: PlantPulseColors.danger,
              background: PlantPulseColors.dangerBg,
            ),
            const SizedBox(height: 10),
            const _Alert(
              title: 'Recheck today',
              subtitle: 'Pepper is due for another inspection',
              time: '1 hr ago',
              icon: Icons.center_focus_strong_rounded,
              color: PlantPulseColors.warning,
              background: PlantPulseColors.warningBg,
            ),
            const SizedBox(height: 10),
            const _Alert(
              title: 'Treatment progress',
              subtitle: 'Potato care step completed',
              time: '3 hr ago',
              icon: Icons.check_circle_outline_rounded,
              color: PlantPulseColors.green,
              background: PlantPulseColors.successBg,
            ),
            const SizedBox(height: 20),
            const Text('Upcoming', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            const _Alert(
              title: 'Spray reminder',
              subtitle: 'Scheduled for tomorrow at 9:00 AM',
              time: 'Tomorrow',
              icon: Icons.schedule_rounded,
              color: PlantPulseColors.green,
              background: PlantPulseColors.mint,
            ),
          ],
        ),
      ),
    );
  }
}

class _Alert extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  final Color background;

  const _Alert({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: PlantPulseColors.muted)),
                ],
              ),
            ),
            Text(time, style: const TextStyle(fontSize: 9, color: PlantPulseColors.muted)),
          ],
        ),
      ),
    );
  }
}
