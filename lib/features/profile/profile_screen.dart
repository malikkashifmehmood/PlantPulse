import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../shared/widgets/plantpulse_scaffold.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';
import '../expert/expert_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlantPulseScaffold(
      currentIndex: 4,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        child: Column(
          children: [
            const PageHeader(title: 'Profile', subtitle: 'Account and plant resources'),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: PlantPulseColors.line),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 31,
                    backgroundColor: PlantPulseColors.mint,
                    child: Icon(Icons.person_rounded, color: PlantPulseColors.green, size: 30),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Farm User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                        SizedBox(height: 3),
                        Text('user@example.com', style: TextStyle(color: PlantPulseColors.muted, fontSize: 11)),
                      ],
                    ),
                  ),
                  Icon(Icons.verified_user_rounded, color: PlantPulseColors.green),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(child: _Stat(value: '24', label: 'Crops')),
                SizedBox(width: 10),
                Expanded(child: _Stat(value: '86', label: 'Scans')),
                SizedBox(width: 10),
                Expanded(child: _Stat(value: '12', label: 'Plans')),
              ],
            ),
            const SizedBox(height: 16),
            _MenuCard(
              icon: Icons.history_rounded,
              title: 'Scan history',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
            ),
            const SizedBox(height: 8),
            _MenuCard(
              icon: Icons.support_agent_rounded,
              title: 'Ask an expert',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpertScreen())),
            ),
            const SizedBox(height: 8),
            _MenuCard(
              icon: Icons.settings_outlined,
              title: 'Settings & privacy',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(label, style: const TextStyle(fontSize: 10, color: PlantPulseColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuCard({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: PlantPulseColors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
