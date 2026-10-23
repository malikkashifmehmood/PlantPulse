import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_theme.dart';
import '../../core/models/plant.dart';
import '../../core/models/plant_diagnosis.dart';
import '../diagnosis/saved_diagnosis_detail_screen.dart';
import '../scan/scan_screen.dart';

class PlantDetailScreen extends StatefulWidget {
  const PlantDetailScreen({super.key, required this.plant});

  final Plant plant;

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  List<PlantDiagnosis> _diagnoses = [];
  bool _isLoading = true;
  String? _error;
  bool _loaded = false;

  String get _scope => FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_loaded) {
      _loaded = true;
      _loadDiagnoses();
    }
  }

  void _loadDiagnoses() {
    try {
      final records = AppServicesScope.of(
        context,
      ).diagnoses.loadForPlant(_scope, widget.plant.id);

      if (!mounted) return;

      setState(() {
        _diagnoses = records;
        _isLoading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Unable to load this plant\'s diagnosis history.';
        _isLoading = false;
      });
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

  Future<void> _scanThisPlant() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => ScanScreen(plant: widget.plant)),
    );

    if (mounted) {
      _loadDiagnoses();
    }
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final plant = widget.plant;
    final latest = _diagnoses.isEmpty ? null : _diagnoses.first;

    final String status;
    final Color statusBackground;
    final Color statusForeground;

    if (latest == null) {
      status = 'Not yet diagnosed';
      statusBackground = Colors.grey.shade100;
      statusForeground = PlantPulseColors.muted;
    } else if (latest.isHealthy) {
      status = 'Healthy';
      statusBackground = PlantPulseColors.successBg;
      statusForeground = PlantPulseColors.green;
    } else {
      status = latest.result;
      statusBackground = PlantPulseColors.warningBg;
      statusForeground = PlantPulseColors.warning;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Plant Details')),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadDiagnoses();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Container(
              height: 170,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  colors: [Color(0xFF274B2F), Color(0xFF75A861)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(Icons.eco_rounded, color: Colors.white, size: 82),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              plant.name,
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text(
              plant.species,
              style: const TextStyle(
                color: PlantPulseColors.muted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: statusBackground,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusForeground,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: PlantPulseColors.mint,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    '${_diagnoses.length} '
                    '${_diagnoses.length == 1 ? 'scan' : 'scans'}',
                    style: const TextStyle(
                      color: PlantPulseColors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_today_outlined,
                  color: PlantPulseColors.green,
                ),
                title: const Text('Added to your garden'),
                subtitle: Text(_formatDate(plant.createdAt)),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                enabled: latest != null,
                onTap: latest == null ? null : () => _openDiagnosis(latest),
                leading: const Icon(
                  Icons.health_and_safety_outlined,
                  color: PlantPulseColors.green,
                ),
                title: const Text('Latest diagnosis'),
                subtitle: Text(
                  latest == null
                      ? 'No saved diagnosis yet'
                      : '${latest.result} · '
                          '${(latest.confidence * 100).round()}% confidence',
                ),
                trailing:
                    latest == null
                        ? null
                        : const Icon(Icons.chevron_right_rounded),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Diagnosis history',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh history',
                  onPressed: () {
                    setState(() => _isLoading = true);
                    _loadDiagnoses();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.error_outline_rounded),
                  title: Text(_error!),
                  trailing: IconButton(
                    onPressed: () {
                      setState(() => _isLoading = true);
                      _loadDiagnoses();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ),
              )
            else if (_diagnoses.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 38,
                        color: PlantPulseColors.green,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'No diagnosis history yet',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Scan this plant to start building its health history.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: PlantPulseColors.muted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._diagnoses.map(
                (diagnosis) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: () => _openDiagnosis(diagnosis),
                    leading: Icon(
                      diagnosis.isHealthy
                          ? Icons.check_circle_outline_rounded
                          : Icons.warning_amber_rounded,
                      color:
                          diagnosis.isHealthy
                              ? PlantPulseColors.green
                              : PlantPulseColors.warning,
                    ),
                    title: Text(
                      diagnosis.result,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      '${_formatDate(diagnosis.createdAt)} · '
                      '${(diagnosis.confidence * 100).round()}% confidence',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _scanThisPlant,
              icon: const Icon(Icons.center_focus_strong_rounded),
              label: const Text('Scan This Plant'),
            ),
          ],
        ),
      ),
    );
  }
}
