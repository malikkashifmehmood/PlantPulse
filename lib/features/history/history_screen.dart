import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../core/models/plant_diagnosis.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/plantpulse_scaffold.dart';

enum _HistoryFilter { all, healthy, issues }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<PlantDiagnosis> _diagnoses = [];
  _HistoryFilter _filter = _HistoryFilter.all;
  bool _loading = true;
  String? _error;
  bool _initialLoadStarted = false;

  String get _scope {
    if (Firebase.apps.isEmpty) return 'guest';

    try {
      return FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    } catch (_) {
      return 'guest';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialLoadStarted) {
      _initialLoadStarted = true;
      _loadHistory();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

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
        _error = AppLocalizations.of(context).historyLoadFailed;
      });
    }
  }

  List<PlantDiagnosis> get _filteredDiagnoses {
    final query = _searchController.text.trim().toLowerCase();

    return _diagnoses.where((diagnosis) {
      final matchesFilter = switch (_filter) {
        _HistoryFilter.all => true,
        _HistoryFilter.healthy => diagnosis.isHealthy,
        _HistoryFilter.issues => !diagnosis.isHealthy,
      };

      final matchesSearch =
          query.isEmpty ||
          diagnosis.plantName.toLowerCase().contains(query) ||
          diagnosis.species.toLowerCase().contains(query) ||
          diagnosis.result.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  DateTime _dateOnly(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  String _formatDateTime(DateTime date) {
    final l10n = AppLocalizations.of(context);
    final local = date.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? l10n.historyTimePm : l10n.historyTimeAm;

    return '${local.day}/${local.month}/${local.year} '
        '${l10n.historyDateSeparator} $hour:$minute $period';
  }

  void _openDiagnosis(PlantDiagnosis diagnosis) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final colors = Theme.of(sheetContext).colorScheme;
        final l10n = AppLocalizations.of(sheetContext);

        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              22,
              12,
              22,
              24 + MediaQuery.viewInsetsOf(sheetContext).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  l10n.historyDiagnosisDetails,
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 18),
                _DetailRow(
                  label: l10n.historyPlant,
                  value: diagnosis.plantName,
                ),
                _DetailRow(
                  label: l10n.historySpecies,
                  value: diagnosis.species,
                ),
                _DetailRow(label: l10n.historyResult, value: diagnosis.result),
                _DetailRow(
                  label: l10n.historyConfidence,
                  value: '${(diagnosis.confidence * 100).toStringAsFixed(1)}%',
                ),
                _DetailRow(
                  label: l10n.historyDate,
                  value: _formatDateTime(diagnosis.createdAt),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.historyRecordedSymptoms,
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                if (diagnosis.symptoms.isEmpty)
                  Text(
                    l10n.historyNoSymptoms,
                    style: Theme.of(sheetContext).textTheme.bodyMedium,
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        diagnosis.symptoms.map((symptom) {
                          return Chip(
                            label: Text(symptom),
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                  ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    l10n.historyImageNotStored,
                    style: Theme.of(sheetContext).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: Text(l10n.historyClose),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filtered = _filteredDiagnoses;
    final today = _dateOnly(DateTime.now());

    final todayItems =
        filtered.where((item) => _dateOnly(item.createdAt) == today).toList();

    final earlierItems =
        filtered
            .where((item) => _dateOnly(item.createdAt).isBefore(today))
            .toList();

    final futureItems =
        filtered
            .where((item) => _dateOnly(item.createdAt).isAfter(today))
            .toList();

    return PlantPulseScaffold(
      currentIndex: 4,
      showBottomNavigation: false,
      child: RefreshIndicator(
        onRefresh: _loadHistory,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth =
                constraints.maxWidth > 720 ? 680.0 : constraints.maxWidth;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PageHeader(
                          title: l10n.historyTitle,
                          subtitle: l10n.historySubtitle,
                          back: true,
                        ),
                        const SizedBox(height: 20),
                        _HistoryBanner(total: _diagnoses.length),
                        const SizedBox(height: 22),
                        TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: l10n.historySearchHint,
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon:
                                _searchController.text.isEmpty
                                    ? null
                                    : IconButton(
                                      tooltip: l10n.historyClearSearch,
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.close_rounded),
                                    ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _filterChip(
                              l10n.historyFilterAll,
                              _HistoryFilter.all,
                            ),
                            _filterChip(
                              l10n.historyFilterHealthy,
                              _HistoryFilter.healthy,
                            ),
                            _filterChip(
                              l10n.historyFilterIssues,
                              _HistoryFilter.issues,
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        if (_loading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 60),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_error != null)
                          _HistoryMessage(
                            icon: Icons.cloud_off_outlined,
                            title: l10n.historyUnableToLoad,
                            message: _error!,
                            actionLabel: l10n.historyTryAgain,
                            onAction: _loadHistory,
                          )
                        else if (_diagnoses.isEmpty)
                          _HistoryMessage(
                            icon: Icons.history_rounded,
                            title: l10n.historyNoScans,
                            message: l10n.historyNoScansDescription,
                          )
                        else if (filtered.isEmpty)
                          _HistoryMessage(
                            icon: Icons.search_off_rounded,
                            title: l10n.historyNoMatches,
                            message: l10n.historyNoMatchesDescription,
                          )
                        else ...[
                          if (todayItems.isNotEmpty) ...[
                            _SectionHeading(
                              title: l10n.historyToday,
                              count: todayItems.length,
                            ),
                            const SizedBox(height: 10),
                            ...todayItems.map(
                              (item) => _HistoryCard(
                                diagnosis: item,
                                dateLabel: _formatDateTime(item.createdAt),
                                onTap: () => _openDiagnosis(item),
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                          if (futureItems.isNotEmpty) ...[
                            _SectionHeading(
                              title: l10n.historyUpcoming,
                              count: futureItems.length,
                            ),
                            const SizedBox(height: 10),
                            ...futureItems.map(
                              (item) => _HistoryCard(
                                diagnosis: item,
                                dateLabel: _formatDateTime(item.createdAt),
                                onTap: () => _openDiagnosis(item),
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                          if (earlierItems.isNotEmpty) ...[
                            _SectionHeading(
                              title: l10n.historyEarlier,
                              count: earlierItems.length,
                            ),
                            const SizedBox(height: 10),
                            ...earlierItems.map(
                              (item) => _HistoryCard(
                                diagnosis: item,
                                dateLabel: _formatDateTime(item.createdAt),
                                onTap: () => _openDiagnosis(item),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _filterChip(String label, _HistoryFilter filter) {
    return FilterChip(
      label: Text(label),
      selected: _filter == filter,
      onSelected: (_) {
        setState(() => _filter = filter);
      },
    );
  }
}

class _HistoryBanner extends StatelessWidget {
  const _HistoryBanner({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.eco_rounded, size: 34, color: colors.onPrimaryContainer),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.historyPlantJourney,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.historySavedCount(total),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onPrimaryContainer,
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

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Text('$count', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.diagnosis,
    required this.dateLabel,
    required this.onTap,
  });

  final PlantDiagnosis diagnosis;
  final String dateLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final healthy = diagnosis.isHealthy;
    final statusColor = healthy ? Colors.green : colors.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.12),
          child: Icon(
            healthy ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            color: statusColor,
          ),
        ),
        title: Text(
          diagnosis.plantName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                diagnosis.result,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                '$dateLabel  ${l10n.historyDateSeparator}  '
                '${(diagnosis.confidence * 100).toStringAsFixed(1)}%',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, size: 48, color: colors.primary),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
