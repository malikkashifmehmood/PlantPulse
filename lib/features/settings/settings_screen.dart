import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final localeScope = AppLocaleScope.of(context);
    final currentLanguage = localeScope.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(strings.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          _Heading(strings.security),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.fingerprint_rounded),
                  title: Text(strings.biometricLock),
                  subtitle: Text(strings.protectDevice),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.devices_other_rounded),
                  title: Text(strings.activeSessions),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.shield_outlined),
                  title: Text(strings.signInSecurity),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _Heading(strings.privacy),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: Text(strings.cameraPermissions),
                  subtitle: Text(strings.cameraPermissionDescription),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.insights_outlined),
                  title: Text(strings.optionalAnalytics),
                  subtitle: Text(strings.analyticsDescription),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: Text(strings.exportInspectionLogs),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _Heading(strings.aiOffline),
          Card(
            child: ListTile(
              leading: const Icon(Icons.model_training_outlined),
              title: Text(strings.modelInformation),
              subtitle: Text(strings.diagnosticModelSubtitle),
            ),
          ),
          const SizedBox(height: 18),
          _Heading(strings.app),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_none_rounded),
                  title: Text(strings.notifications),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: Text(strings.language),
                  trailing: DropdownButton<String>(
                    value: currentLanguage,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(strings.english),
                      ),
                      DropdownMenuItem(value: 'ur', child: Text(strings.urdu)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        localeScope.setLocale(Locale(value));
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.straighten_rounded),
                  title: Text(strings.units),
                  trailing: Text(strings.metric),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _Heading(strings.dangerZone),
          Card(
            color: PlantPulseColors.dangerBg,
            child: ListTile(
              leading: const Icon(
                Icons.delete_forever_outlined,
                color: PlantPulseColors.danger,
              ),
              title: Text(
                strings.deleteAccount,
                style: const TextStyle(
                  color: PlantPulseColors.danger,
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text(strings.deleteAccountDescription),
              trailing: const Icon(
                Icons.info_outline_rounded,
                color: PlantPulseColors.danger,
              ),
              onTap: () => _showDeleteInformation(context, strings),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteInformation(
    BuildContext context,
    AppLocalizations strings,
  ) async {
    await showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(strings.deleteAccountConfirmation),
            content: Text(strings.deleteAccountPlaceholder),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(strings.cancel),
              ),
            ],
          ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

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
