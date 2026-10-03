import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool biometric = true;
  bool alerts = true;
  bool offline = true;
  bool analytics = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          const _Heading('SECURITY'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: biometric,
                  onChanged: (v) => setState(() => biometric = v),
                  title: const Text('Biometric lock', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text('Protect the app on this device'),
                  secondary: const Icon(Icons.fingerprint_rounded),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.devices_other_rounded),
                  title: Text('Active sessions'),
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.shield_outlined),
                  title: Text('Sign-in security'),
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _Heading('PRIVACY'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.camera_alt_outlined),
                  title: Text('Camera permissions'),
                  subtitle: Text('Only requested when scanning'),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: analytics,
                  onChanged: (v) => setState(() => analytics = v),
                  title: const Text('Optional analytics'),
                  subtitle: const Text('Off by default'),
                  secondary: const Icon(Icons.insights_outlined),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.file_download_outlined),
                  title: Text('Export inspection logs'),
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _Heading('AI & OFFLINE'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: offline,
                  onChanged: (v) => setState(() => offline = v),
                  title: const Text('Offline model', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text('Use supported on-device diagnosis'),
                  secondary: const Icon(Icons.phonelink_lock_rounded),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.model_training_outlined),
                  title: Text('Model information'),
                  subtitle: Text('PlantPulse Diagnostic Model'),
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _Heading('APP'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: alerts,
                  onChanged: (v) => setState(() => alerts = v),
                  title: const Text('Notifications'),
                  secondary: const Icon(Icons.notifications_none_rounded),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.language_rounded),
                  title: Text('Language'),
                  trailing: Text('English'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.straighten_rounded),
                  title: Text('Units'),
                  trailing: Text('Metric'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _Heading('DANGER ZONE'),
          Card(
            color: PlantPulseColors.dangerBg,
            child: ListTile(
              leading: const Icon(Icons.delete_forever_outlined, color: PlantPulseColors.danger),
              title: const Text(
                'Delete account',
                style: TextStyle(
                  color: PlantPulseColors.danger,
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: const Text('Requires confirmation before any destructive action'),
              trailing: const Icon(Icons.chevron_right_rounded, color: PlantPulseColors.danger),
              onTap: () => _confirmDelete(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This is a UI placeholder. Production account deletion must require authenticated, server-side authorization and explicit confirmation.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;

  const _Heading(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: PlantPulseColors.muted,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.3,
        ),
      ),
    );
  }
}
