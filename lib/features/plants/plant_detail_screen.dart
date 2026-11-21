import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_theme.dart';
import '../../core/models/plant.dart';
import '../../core/models/plant_diagnosis.dart';
import '../../l10n/app_localizations.dart';
import '../diagnosis/saved_diagnosis_detail_screen.dart';
import '../scan/scan_screen.dart';

class PlantDetailScreen extends StatefulWidget {
  const PlantDetailScreen({super.key, required this.plant});

  final Plant plant;

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  late final String _scope;

  List<PlantDiagnosis> _diagnoses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scope = _resolveScope();
  }

  String _resolveScope() {
    try {
      if (Firebase.apps.isEmpty) return 'guest';
      return FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    } catch (_) {
      return 'guest';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isLoading && _diagnoses.isEmpty && _error == null) {
      _loadDiagnoses();
    }
  }

  Future<void> _loadDiagnoses({bool showLoading = false}) async {
    if (showLoading && mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final diagnoses = AppServicesScope.of(
        context,
      ).diagnoses.loadForPlant(_scope, widget.plant.id);

      if (!mounted) return;

      setState(() {
        // DiagnosisRepository returns records newest first.
        _diagnoses = diagnoses;
        _error = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = AppLocalizations.of(context).plantDetailLoadFailed;
        _isLoading = false;
      });
    }
  }

  Future<void> _scanThisPlant() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => ScanScreen(plant: widget.plant)),
    );

    if (mounted) {
      await _loadDiagnoses(showLoading: true);
    }
  }

  void _openDiagnosis(PlantDiagnosis diagnosis) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SavedDiagnosisDetailScreen(diagnosis: diagnosis),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }

  String _formatDateTime(DateTime date) {
    final local = date.toLocal();
    final dateText = _formatDate(local);
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '$dateText · $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final latestDiagnosis = _diagnoses.isEmpty ? null : _diagnoses.first;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.plantDetailTitle)),
      body: RefreshIndicator(
        onRefresh: _loadDiagnoses,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF274B2F), Color(0xFF75A861)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.eco_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.plant.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.plant.species,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 13,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                latestDiagnosis == null
                                    ? l10n.plantDetailNotDiagnosed
                                    : latestDiagnosis.isHealthy
                                    ? l10n.plantDetailLatestHealthy
                                    : l10n.plantDetailLatestResult(
                                      latestDiagnosis.result,
                                    ),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.document_scanner_outlined,
                              label: l10n.plantDetailTotalScans,
                              value: _isLoading ? '—' : '${_diagnoses.length}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.calendar_today_outlined,
                              label: l10n.plantDetailAddedOn,
                              value: _formatDate(widget.plant.createdAt),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.plantDetailLatestDiagnosis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_isLoading)
                        const _LoadingState()
                      else if (_error != null)
                        _MessageState(
                          icon: Icons.cloud_off_rounded,
                          message: _error!,
                          actionLabel: l10n.plantDetailTryAgain,
                          onAction: () => _loadDiagnoses(showLoading: true),
                        )
                      else if (latestDiagnosis == null)
                        _MessageState(
                          icon: Icons.document_scanner_outlined,
                          message: l10n.plantDetailNoDiagnosis,
                        )
                      else
                        _DiagnosisCard(
                          diagnosis: latestDiagnosis,
                          dateText: _formatDateTime(latestDiagnosis.createdAt),
                          onTap: () => _openDiagnosis(latestDiagnosis),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.plantDetailHistory,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (!_isLoading && _error == null)
                            Text(
                              _diagnoses.length == 1
                                  ? l10n.plantDetailRecordCountSingular(
                                    _diagnoses.length,
                                  )
                                  : l10n.plantDetailRecordCount(
                                    _diagnoses.length,
                                  ),
                              style: const TextStyle(
                                color: PlantPulseColors.muted,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_isLoading)
                        const _LoadingState()
                      else if (_error != null)
                        _MessageState(
                          icon: Icons.info_outline_rounded,
                          message: l10n.plantDetailHistoryUnavailable,
                        )
                      else if (_diagnoses.isEmpty)
                        _MessageState(
                          icon: Icons.history_rounded,
                          message: l10n.plantDetailHistoryEmpty,
                        )
                      else
                        ..._diagnoses.map(
                          (diagnosis) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _DiagnosisCard(
                              diagnosis: diagnosis,
                              dateText: _formatDateTime(diagnosis.createdAt),
                              onTap: () => _openDiagnosis(diagnosis),
                            ),
                          ),
                        ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _scanThisPlant,
                          icon: const Icon(Icons.camera_alt_rounded),
                          label: Text(l10n.plantDetailScanButton),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: PlantPulseColors.green, size: 22),
            const SizedBox(height: 10),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              label,
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
    );
  }
}

class _DiagnosisCard extends StatelessWidget {
  const _DiagnosisCard({
    required this.diagnosis,
    required this.dateText,
    required this.onTap,
  });

  final PlantDiagnosis diagnosis;
  final String dateText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final healthy = diagnosis.isHealthy;
    final confidence = (diagnosis.confidence * 100).round();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      healthy
                          ? PlantPulseColors.mint
                          : PlantPulseColors.warningBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  healthy
                      ? Icons.check_circle_outline_rounded
                      : Icons.health_and_safety_outlined,
                  color:
                      healthy
                          ? PlantPulseColors.green
                          : PlantPulseColors.warning,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diagnosis.result,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      dateText,
                      style: const TextStyle(
                        color: PlantPulseColors.muted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(
                        context,
                      ).plantDetailModelScore(confidence),
                      style: const TextStyle(
                        color: PlantPulseColors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
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

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: PlantPulseColors.green),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: PlantPulseColors.muted,
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
