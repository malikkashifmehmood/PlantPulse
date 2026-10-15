import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../shared/widgets/plantpulse_scaffold.dart';
import '../scan/scan_screen.dart';

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
            const SizedBox(height: 24),
            const _HealthCard(),
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    icon: Icons.eco_outlined,
                    title: 'Plants',
                    value: '12',
                    detail: 'In your garden',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(
                    icon: Icons.document_scanner_outlined,
                    title: 'Scans',
                    value: '28',
                    detail: 'Total inspections',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionTitle(
              title: 'Quick actions',
              trailing: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScanScreen()),
                  );
                },
                child: const Text('Scan now'),
              ),
            ),
            const SizedBox(height: 10),
            _AlertCard(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScanScreen()),
                );
              },
            ),
            const SizedBox(height: 24),
            const _SectionTitle(title: 'Your plants'),
            const SizedBox(height: 10),
            const _PlantRow(
              name: 'Tomato Roma',
              detail: 'Last scan: today',
              status: 'Needs attention',
              icon: Icons.local_florist_rounded,
            ),
            const SizedBox(height: 8),
            const _PlantRow(
              name: 'Green Pepper',
              detail: 'Last scan: 2 days ago',
              status: 'Healthy',
              icon: Icons.spa_rounded,
            ),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Recent scans'),
            const SizedBox(height: 10),
            const _RecentScan(
              title: 'Tomato Roma',
              result: 'Early Blight',
              confidence: '92%',
            ),
            const SizedBox(height: 8),
            const _RecentScan(
              title: 'Potato',
              result: 'Healthy',
              confidence: '96%',
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PlantPulseColors.cream,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PlantPulseColors.line),
              ),
              child: const Text(
                'Recent scans shown here are sample entries. '
                'Start a new scan to analyze a leaf image.',
                style: TextStyle(
                  color: PlantPulseColors.muted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning, Ali',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: PlantPulseColors.forest,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Let’s keep your garden thriving.',
                style: TextStyle(color: PlantPulseColors.muted, fontSize: 13),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: PlantPulseColors.mint,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PlantPulseColors.line),
          ),
          child: const Icon(
            Icons.eco_rounded,
            color: PlantPulseColors.forest,
            size: 27,
          ),
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
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PlantPulseColors.forest, PlantPulseColors.green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Garden health',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: PlantPulseColors.bright,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '87',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5, left: 5),
                child: Text(
                  '/100',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: const LinearProgressIndicator(
              value: 0.87,
              minHeight: 8,
              backgroundColor: Color(0x44FFFFFF),
              valueColor: AlwaysStoppedAnimation<Color>(
                PlantPulseColors.bright,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Sample garden overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String detail;

  const _MiniStat({
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PlantPulseColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: PlantPulseColors.green, size: 23),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: PlantPulseColors.forest,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            detail,
            style: const TextStyle(color: PlantPulseColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: PlantPulseColors.forest,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AlertCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PlantPulseColors.warningBg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.document_scanner_outlined,
                  color: PlantPulseColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check your plants',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: PlantPulseColors.ink,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Scan a leaf to check for possible disease.',
                      style: TextStyle(
                        color: PlantPulseColors.muted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: PlantPulseColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlantRow extends StatelessWidget {
  final String name;
  final String detail;
  final String status;
  final IconData icon;

  const _PlantRow({
    required this.name,
    required this.detail,
    required this.status,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isHealthy = status == 'Healthy';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PlantPulseColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: PlantPulseColors.mint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: PlantPulseColors.green, size: 25),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text(
                  detail,
                  style: const TextStyle(
                    color: PlantPulseColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color:
                  isHealthy
                      ? PlantPulseColors.successBg
                      : PlantPulseColors.warningBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color:
                    isHealthy
                        ? PlantPulseColors.green
                        : PlantPulseColors.warning,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentScan extends StatelessWidget {
  final String title;
  final String result;
  final String confidence;

  const _RecentScan({
    required this.title,
    required this.result,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final isHealthy = result.toLowerCase() == 'healthy';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PlantPulseColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
                  isHealthy
                      ? PlantPulseColors.successBg
                      : PlantPulseColors.dangerBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isHealthy ? Icons.eco_rounded : Icons.warning_amber_rounded,
              color:
                  isHealthy ? PlantPulseColors.green : PlantPulseColors.danger,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  result,
                  style: const TextStyle(
                    color: PlantPulseColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            confidence,
            style: TextStyle(
              color:
                  isHealthy ? PlantPulseColors.green : PlantPulseColors.danger,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
