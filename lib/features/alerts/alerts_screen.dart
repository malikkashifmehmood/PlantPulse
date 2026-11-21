import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_theme.dart';
import '../../core/models/plant_diagnosis.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/plantpulse_scaffold.dart';
import '../history/history_screen.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<PlantDiagnosis> _diagnoses = [];
  bool _loading = true;
  bool _loadStarted = false;
  String? _error;

  String get _scope {
    try {
      if (Firebase.apps.isEmpty) return 'guest';
      return FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    } catch (_) {
      return 'guest';
    }
  }

  List<PlantDiagnosis> get _issues =>
      _diagnoses.where((diagnosis) => !diagnosis.isHealthy).toList();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_loadStarted) {
      _loadStarted = true;
      _loadAlerts();
    }
  }

  Future<void> _loadAlerts() async {
    try {
      final diagnoses = AppServicesScope.of(
        context,
      ).diagnoses.loadDiagnoses(_scope);

      if (!mounted) return;

      setState(() {
        _diagnoses = diagnoses;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context).alertsLoadFailed;
      });
    }
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const HistoryScreen()),
    );
  }

  String _formatDate(DateTime dateTime, AppLocalizations l10n) {
    final local = dateTime.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? l10n.alertsPm : l10n.alertsAm;

    return '${local.day}/${local.month}/${local.year} · $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final issues = _issues;

    return PlantPulseScaffold(
      currentIndex: 3,
      child: RefreshIndicator(
        onRefresh: _loadAlerts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: l10n.alertsTitle,
                subtitle: l10n.alertsSubtitle,
              ),
              const SizedBox(height: 22),

              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 70),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                _MessageCard(
                  icon: Icons.error_outline_rounded,
                  message: _error!,
                  actionLabel: l10n.tryAgain,
                  onAction: _loadAlerts,
                )
              else if (_diagnoses.isEmpty)
                _MessageCard(
                  icon: Icons.notifications_none_rounded,
                  message: l10n.alertsNoUpdates,
                )
              else ...[
                _OverviewCard(
                  totalInspections: _diagnoses.length,
                  issueCount: issues.length,
                ),
                const SizedBox(height: 22),

                if (issues.isNotEmpty) ...[
                  Text(
                    l10n.alertsNeedsAttention(issues.length),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...issues.map(
                    (diagnosis) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DiagnosisAlertCard(
                        diagnosis: diagnosis,
                        dateLabel: _formatDate(diagnosis.createdAt, l10n),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ] else
                  _MessageCard(
                    icon: Icons.check_circle_outline_rounded,
                    message: l10n.alertsNoUnhealthy,
                  ),

                Text(
                  l10n.alertsRecentInspections(_diagnoses.length),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),

                ..._diagnoses
                    .take(5)
                    .map(
                      (diagnosis) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _DiagnosisAlertCard(
                          diagnosis: diagnosis,
                          dateLabel: _formatDate(diagnosis.createdAt, l10n),
                        ),
                      ),
                    ),

                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _openHistory,
                  icon: const Icon(Icons.history_rounded),
                  label: Text(l10n.alertsViewHistory),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.totalInspections,
    required this.issueCount,
  });

  final int totalInspections;
  final int issueCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasIssues = issueCount > 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            hasIssues ? PlantPulseColors.warningBg : PlantPulseColors.successBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasIssues
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline_rounded,
            size: 34,
            color:
                hasIssues ? PlantPulseColors.warning : PlantPulseColors.green,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasIssues
                      ? l10n.alertsUnhealthyCount(issueCount)
                      : l10n.alertsNoUnhealthyResults,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.alertsSavedCount(totalInspections),
                  style: const TextStyle(
                    color: PlantPulseColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagnosisAlertCard extends StatelessWidget {
  const _DiagnosisAlertCard({required this.diagnosis, required this.dateLabel});

  final PlantDiagnosis diagnosis;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final healthy = diagnosis.isHealthy;
    final color = healthy ? PlantPulseColors.green : PlantPulseColors.danger;
    final background =
        healthy ? PlantPulseColors.successBg : PlantPulseColors.dangerBg;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    healthy ? Icons.eco_rounded : Icons.warning_amber_rounded,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      diagnosis.plantName,
                      softWrap: true,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: Text(
                diagnosis.result,
                softWrap: true,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Keep metadata as independent wrapping items.
            // Avoid a nested Row that can overflow on narrow RTL layouts.
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Text(
                  dateLabel,
                  softWrap: true,
                  style: const TextStyle(
                    color: PlantPulseColors.muted,
                    fontSize: 11,
                  ),
                ),
                Text(
                  '${(diagnosis.confidence * 100).round()}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.w900),
                ),
                Text(
                  l10n.alertsModelScore,
                  softWrap: true,
                  style: const TextStyle(
                    color: PlantPulseColors.muted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PlantPulseColors.cream,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 38, color: PlantPulseColors.green),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(height: 1.5),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
