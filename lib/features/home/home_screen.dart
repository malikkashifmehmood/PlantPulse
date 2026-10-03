import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../shared/widgets/plantpulse_scaffold.dart';
import '../scan/scan_screen.dart';
import '../diagnosis/diagnosis_screen.dart';
import '../alerts/alerts_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlantPulseScaffold(
      currentIndex: 0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TopBar(),
            const SizedBox(height: 22),
            const _HealthCard(),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Active plants',
                    value: '12',
                    icon: Icons.local_florist_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(
                    label: 'Need attention',
                    value: '2',
                    icon: Icons.priority_high_rounded,
                    warning: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScanScreen()),
                );
              },
              icon: const Icon(Icons.center_focus_strong_rounded),
              label: const Text('Scan a Leaf'),
            ),
            const SizedBox(height: 18),
            _SectionTitle(
              title: 'Garden alerts',
              action: 'View all',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AlertsScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            const _AlertCard(),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Plants needing attention'),
            const SizedBox(height: 10),
            const _PlantRow(
              name: 'Tomato Roma',
              detail: 'Possible early blight',
              status: 'Attention',
              icon: Icons.eco_rounded,
              danger: true,
            ),
            const SizedBox(height: 8),
            const _PlantRow(
              name: 'Green Pepper',
              detail: 'Last scan 2 days ago',
              status: 'Healthy',
              icon: Icons.spa_rounded,
            ),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Recent scans'),
            const SizedBox(height: 10),
            _RecentScan(
              title: 'Tomato Roma',
              result: 'Early Blight',
              confidence: '92%',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DiagnosisScreen()),
              ),
            ),
            const SizedBox(height: 8),
            const _RecentScan(
              title: 'Potato',
              result: 'Healthy',
              confidence: '96%',
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning',
                style: TextStyle(color: PlantPulseColors.muted, fontSize: 13),
              ),
              SizedBox(height: 2),
              Text(
                'Your garden today',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: PlantPulseColors.line),
          ),
          child: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}

class _HealthCard extends StatelessWidget {
  const _HealthCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PlantPulseColors.forest, PlantPulseColors.green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            height: 92,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: .87,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withValues(alpha: .14),
                  color: PlantPulseColors.bright,
                ),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '87%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'healthy',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Garden health',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Most plants are doing well. Two need a closer look.',
                  style: TextStyle(color: Colors.white70, height: 1.4, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool warning;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: warning ? PlantPulseColors.warningBg : PlantPulseColors.mint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: warning ? PlantPulseColors.warning : PlantPulseColors.green,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: PlantPulseColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onTap;

  const _SectionTitle({required this.title, this.action, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onTap,
            child: Text(action!),
          ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PlantPulseColors.warningBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE3B2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.water_drop_outlined, color: PlantPulseColors.warning),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'High humidity today',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 3),
                Text(
                  'Check airflow around your tomato plants.',
                  style: TextStyle(fontSize: 11, color: PlantPulseColors.muted),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _PlantRow extends StatelessWidget {
  final String name;
  final String detail;
  final String status;
  final IconData icon;
  final bool danger;

  const _PlantRow({
    required this.name,
    required this.detail,
    required this.status,
    required this.icon,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: PlantIcon(size: 44),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(detail, style: const TextStyle(fontSize: 11)),
        trailing: StatusPill(
          text: status,
          background: danger ? PlantPulseColors.dangerBg : PlantPulseColors.successBg,
          foreground: danger ? PlantPulseColors.danger : PlantPulseColors.green,
        ),
      ),
    );
  }
}

class _RecentScan extends StatelessWidget {
  final String title;
  final String result;
  final String confidence;
  final VoidCallback? onTap;

  const _RecentScan({
    required this.title,
    required this.result,
    required this.confidence,
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
              const PlantIcon(size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text(result, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              StatusPill(
                text: confidence,
                background: PlantPulseColors.successBg,
                foreground: PlantPulseColors.green,
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right_rounded, color: PlantPulseColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
