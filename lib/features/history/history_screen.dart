import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_theme.dart';
import '../../core/models/plant_diagnosis.dart';
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

  String get _scope => FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final records = AppServicesScope.of(
        context,
      ).diagnoses.loadDiagnoses(_scope);

      if (!mounted) return;

      setState(() {
        _diagnoses = records;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Saved scan history could not be loaded.';
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

  void _openDiagnosis(PlantDiagnosis diagnosis) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final healthy = diagnosis.isHealthy;
        final color =
            healthy ? PlantPulseColors.green : PlantPulseColors.danger;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor:
                          healthy
                              ? PlantPulseColors.successBg
                              : PlantPulseColors.dangerBg,
                      child: Icon(
                        healthy
                            ? Icons.eco_rounded
                            : Icons.warning_amber_rounded,
                        color: color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        diagnosis.plantName,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'DIAGNOSIS',
                  style: TextStyle(
                    color: PlantPulseColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  diagnosis.result,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                const SizedBox(height: 18),
                _DetailRow(
                  label: 'Confidence',
                  value: '${(diagnosis.confidence * 100).round()}%',
                ),
                _DetailRow(
                  label: 'Plant species',
                  value:
                      diagnosis.species.isEmpty
                          ? 'Not recorded'
                          : diagnosis.species,
                ),
                _DetailRow(
                  label: 'Date and time',
                  value: _formatDateTime(diagnosis.createdAt),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Recorded symptoms',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                if (diagnosis.symptoms.isEmpty)
                  const Text(
                    'No symptoms were saved for this diagnosis.',
                    style: TextStyle(
                      color: PlantPulseColors.muted,
                      height: 1.5,
                    ),
                  )
                else
                  ...diagnosis.symptoms.map(
                    (symptom) => Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.circle, size: 7, color: color),
                          const SizedBox(width: 10),
                          Expanded(child: Text(symptom)),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PlantPulseColors.cream,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'This record contains saved diagnosis information. '
                    'The original scan image is not stored in this record.',
                    style: TextStyle(height: 1.45, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text('Close details'),
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
    final records = _filteredDiagnoses;
    final today = DateUtils.dateOnly(DateTime.now());

    final todaysRecords =
        records.where((item) {
          return !item.createdAt.isBefore(today);
        }).toList();

    final earlierRecords =
        records.where((item) {
          return item.createdAt.isBefore(today);
        }).toList();

    return PlantPulseScaffold(
      currentIndex: 4,
      child: RefreshIndicator(
        onRefresh: _loadHistory,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            const PageHeader(
              title: 'Scan History',
              subtitle: 'Your saved plant inspections',
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [PlantPulseColors.forest, PlantPulseColors.green],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your plant journey',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Review your saved diagnosis records.',
                          style: TextStyle(color: Colors.white70, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.history_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search plant or diagnosis',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon:
                    _searchController.text.isEmpty
                        ? null
                        : IconButton(
                          tooltip: 'Clear search',
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
                _filterChip('All', _HistoryFilter.all),
                _filterChip('Healthy', _HistoryFilter.healthy),
                _filterChip('Issues', _HistoryFilter.issues),
              ],
            ),
            const SizedBox(height: 22),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _MessageCard(
                icon: Icons.cloud_off_rounded,
                message: _error!,
                actionLabel: 'Try again',
                onAction: _loadHistory,
              )
            else if (_diagnoses.isEmpty)
              const _MessageCard(
                icon: Icons.document_scanner_outlined,
                message:
                    'No saved diagnoses yet. Scan a plant and save its '
                    'diagnosis to start building your history.',
              )
            else if (records.isEmpty)
              const _MessageCard(
                icon: Icons.search_off_rounded,
                message: 'No records match your search or selected filter.',
              )
            else ...[
              _section(title: 'Today', items: todaysRecords),
              if (earlierRecords.isNotEmpty) ...[
                const SizedBox(height: 22),
                _section(title: 'Earlier', items: earlierRecords),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, _HistoryFilter value) {
    return FilterChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: PlantPulseColors.mint,
      checkmarkColor: PlantPulseColors.forest,
    );
  }

  Widget _section({
    required String title,
    required List<PlantDiagnosis> items,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title (${items.length})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        ...items.map(
          (diagnosis) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _HistoryCard(
              diagnosis: diagnosis,
              onTap: () => _openDiagnosis(diagnosis),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.diagnosis, required this.onTap});

  final PlantDiagnosis diagnosis;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final healthy = diagnosis.isHealthy;
    final resultColor =
        healthy ? PlantPulseColors.green : PlantPulseColors.danger;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        leading: CircleAvatar(
          backgroundColor:
              healthy ? PlantPulseColors.successBg : PlantPulseColors.dangerBg,
          child: Icon(
            healthy ? Icons.eco_rounded : Icons.warning_amber_rounded,
            color: resultColor,
          ),
        ),
        title: Text(
          diagnosis.plantName,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(diagnosis.result),
              const SizedBox(height: 4),
              Text(
                _formatDateTime(diagnosis.createdAt),
                style: const TextStyle(
                  color: PlantPulseColors.muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${(diagnosis.confidence * 100).round()}%',
              style: TextStyle(fontWeight: FontWeight.w900, color: resultColor),
            ),
            const SizedBox(height: 4),
            const Text('Confidence', style: TextStyle(fontSize: 10)),
            const SizedBox(height: 3),
            Icon(Icons.chevron_right_rounded, size: 17, color: resultColor),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: PlantPulseColors.muted),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
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

String _formatDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';

  return '${local.day}/${local.month}/${local.year} · '
      '$hour:$minute $period';
}

