import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/plantpulse_scaffold.dart';
import '../auth/auth_screen.dart';
import '../expert/expert_screen.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.auth});

  final FirebaseAuth? auth;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _signingOut = false;
  bool _statsLoaded = false;
  bool _statsUnavailable = false;

  int _plantCount = 0;
  int _diagnosisCount = 0;

  FirebaseAuth? get _auth {
    if (widget.auth != null) return widget.auth;

    if (Firebase.apps.isEmpty) return null;

    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_statsLoaded) return;
    _statsLoaded = true;

    _loadProfileStats();
  }

  void _loadProfileStats() {
    try {
      final scope = _auth?.currentUser?.uid ?? 'guest';
      final services = AppServicesScope.of(context);

      _plantCount = services.plants.loadPlants(scope).length;
      _diagnosisCount = services.diagnoses.loadDiagnoses(scope).length;
    } catch (error, stackTrace) {
      debugPrint('PlantPulse profile statistics failed: ${error.runtimeType}');
      debugPrintStack(stackTrace: stackTrace);
      _statsUnavailable = true;
    }
  }

  String _displayName(User? user, AppLocalizations l10n) {
    if (user == null || user.isAnonymous) {
      return l10n.profileGuest;
    }

    final name = user.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return l10n.profileUser;
  }

  String _displayEmail(User? user, AppLocalizations l10n) {
    if (user == null || user.isAnonymous) {
      return l10n.profileGuestAccount;
    }

    return user.email ?? l10n.profileEmailUnavailable;
  }

  Future<void> _signOut() async {
    if (_signingOut) return;

    final auth = _auth;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (auth == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.profileAuthUnavailable)),
      );
      return;
    }

    final services = AppServicesScope.of(context);

    setState(() => _signingOut = true);

    try {
      await auth.signOut();

      var localCleanupFailed = false;

      try {
        await services.security.signOut();
      } catch (_) {
        localCleanupFailed = true;
      }

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil<void>(
        MaterialPageRoute<void>(builder: (_) => AuthScreen(auth: widget.auth)),
        (route) => false,
      );

      if (localCleanupFailed) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.profileCleanupWarning)),
        );
      }
    } catch (_) {
      if (!mounted) return;

      setState(() => _signingOut = false);

      messenger.showSnackBar(
        SnackBar(content: Text(l10n.profileSignOutFailed)),
      );
    }
  }

  void _openScreen(Widget screen) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = _auth?.currentUser;

    return PlantPulseScaffold(
      currentIndex: 4,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PageHeader(
                    title: l10n.profileTitle,
                    subtitle: l10n.profileSubtitle,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: PlantPulseColors.line),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 31,
                          backgroundColor: PlantPulseColors.mint,
                          child: Icon(
                            Icons.person_rounded,
                            color: PlantPulseColors.green,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _displayName(user, l10n),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _displayEmail(user, l10n),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: PlantPulseColors.muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.verified_user_rounded,
                          color: PlantPulseColors.green,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Stat(
                          value: _statsUnavailable ? '-' : '$_plantCount',
                          label: l10n.profilePlants,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Stat(
                          value: _statsUnavailable ? '-' : '$_diagnosisCount',
                          label: l10n.profileScans,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _MenuCard(
                    icon: Icons.history_rounded,
                    title: l10n.profileScanHistory,
                    onTap: () => _openScreen(const HistoryScreen()),
                  ),
                  const SizedBox(height: 8),
                  _MenuCard(
                    icon: Icons.support_agent_rounded,
                    title: l10n.profileAskExpert,
                    onTap: () => _openScreen(const ExpertScreen()),
                  ),
                  const SizedBox(height: 8),
                  _MenuCard(
                    icon: Icons.settings_outlined,
                    title: l10n.profileSettingsPrivacy,
                    onTap: () => _openScreen(const SettingsScreen()),
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: _signingOut ? null : _signOut,
                    icon:
                        _signingOut
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.logout_rounded),
                    label: Text(
                      _signingOut
                          ? l10n.profileSigningOut
                          : l10n.profileSignOut,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 3),
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
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

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
