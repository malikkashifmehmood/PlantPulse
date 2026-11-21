import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_theme.dart';
import '../../core/models/plant.dart';
import '../../core/models/plant_diagnosis.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/forest_backdrop.dart';
import '../../shared/widgets/plantpulse_scaffold.dart';
import '../plants/plants_screen.dart';
import '../scan/scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _scope = 'guest';
  bool _initialized = false;
  bool _isLoading = true;
  String? _error;

  List<Plant> _plants = [];
  List<PlantDiagnosis> _diagnoses = [];
  Map<String, PlantDiagnosis> _latestByPlant = {};

  Color get _glass => Colors.white.withValues(alpha: .93);

  User? get _currentUser {
    try {
      if (Firebase.apps.isEmpty) return null;
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initialized = true;
      _scope = _currentUser?.uid ?? 'guest';
      _loadDashboard();
    }
  }

  Future<void> _loadDashboard() async {
    try {
      final services = AppServicesScope.of(context);

      final plants = services.plants.loadPlants(_scope);
      final diagnoses = services.diagnoses.loadDiagnoses(_scope);

      final latestByPlant = <String, PlantDiagnosis>{};

      for (final diagnosis in diagnoses) {
        latestByPlant.putIfAbsent(diagnosis.plantId, () => diagnosis);
      }

      if (!mounted) return;

      setState(() {
        _plants = plants;
        _diagnoses = diagnoses;
        _latestByPlant = latestByPlant;
        _error = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = AppLocalizations.of(context).dashboardLoadError;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshDashboard() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    await _loadDashboard();
  }

  int get _healthyCount =>
      _latestByPlant.values.where((item) => item.isHealthy).length;

  int get _attentionCount =>
      _latestByPlant.values.where((item) => !item.isHealthy).length;

  List<Plant> get _recentPlants {
    final plants = List<Plant>.from(_plants)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return plants.take(3).toList();
  }

  List<PlantDiagnosis> get _recentDiagnoses {
    final diagnoses = List<PlantDiagnosis>.from(_diagnoses)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return diagnoses.take(3).toList();
  }

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    final name = _currentUser?.displayName?.trim();

    final displayName = name != null && name.isNotEmpty ? name : l10n.gardener;

    if (hour < 12) return l10n.goodMorning(displayName);
    if (hour < 17) return l10n.goodAfternoon(displayName);
    return l10n.goodEvening(displayName);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PlantPulseScaffold(
      currentIndex: 0,
      child: Stack(
        children: [
          const Positioned.fill(child: ForestBackdrop()),
          RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 600 ? 32.0 : 20.0;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                28,
              ),
              children: [
                _buildHeader(context, l10n),
                const SizedBox(height: 24),
                _buildQuickActions(context, l10n),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                else if (_error != null)
                  _buildErrorState(context, l10n)
                else ...[
                  _buildOverview(context, l10n),
                  const SizedBox(height: 24),
                  _buildRecentPlants(context, l10n),
                  const SizedBox(height: 24),
                  _buildRecentScans(context, l10n),
                ],
              ],
            );
          },
        ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(l10n),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFCDEBD6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.gardenGreeting,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontFamily: 'serif',
                  fontSize: 24,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  shadows: const [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const PlantIcon(size: 48),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;

        return Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScanScreen()),
                  ).then((_) => _refreshDashboard());
                },
                style: FilledButton.styleFrom(
                  backgroundColor: PlantPulseColors.bright,
                  foregroundColor: const Color(0xFF062416),
                ),
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(compact ? l10n.scan : l10n.scanLeaf),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PlantsScreen()),
                  ).then((_) => _refreshDashboard());
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: .12),
                  side: BorderSide(color: Colors.white.withValues(alpha: .55)),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.local_florist_outlined),
                label: Text(l10n.myPlants),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverview(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.gardenOverview,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontFamily: 'serif',
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 500 ? 4 : 2;
            final cardWidth =
                (constraints.maxWidth - (columns - 1) * 12) / columns;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _statCard(
                  context,
                  width: cardWidth,
                  title: l10n.myPlants,
                  value: _plants.length.toString(),
                  icon: Icons.eco_outlined,
                ),
                _statCard(
                  context,
                  width: cardWidth,
                  title: l10n.totalScans,
                  value: _diagnoses.length.toString(),
                  icon: Icons.document_scanner_outlined,
                ),
                _statCard(
                  context,
                  width: cardWidth,
                  title: l10n.healthy,
                  value: _healthyCount.toString(),
                  icon: Icons.check_circle_outline,
                ),
                _statCard(
                  context,
                  width: cardWidth,
                  title: l10n.needsAttention,
                  value: _attentionCount.toString(),
                  icon: Icons.warning_amber_outlined,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _statCard(
    BuildContext context, {
    required double width,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return SizedBox(
      width: width,
      child: Card(
      color: _glass,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: PlantPulseColors.green, size: 24),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: PlantPulseColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: PlantPulseColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentPlants(BuildContext context, AppLocalizations l10n) {
    final plants = _recentPlants;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recentPlants,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontFamily: 'serif',
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
          ),
        ),
        const SizedBox(height: 12),
        if (plants.isEmpty)
          _emptyCard(icon: Icons.eco_outlined, message: l10n.noPlantsYet)
        else
          ...plants.map((plant) {
            final diagnosis = _latestByPlant[plant.id];

            return Card(
      color: _glass,
              child: ListTile(
                leading: const PlantIcon(size: 40),
                title: Text(
                  plant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  diagnosis == null
                      ? plant.species
                      : '${plant.species} • ${diagnosis.result}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PlantsScreen()),
                  ).then((_) => _refreshDashboard());
                },
              ),
            );
          }),
      ],
    );
  }

  Widget _buildRecentScans(BuildContext context, AppLocalizations l10n) {
    final diagnoses = _recentDiagnoses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recentScans,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontFamily: 'serif',
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
          ),
        ),
        const SizedBox(height: 12),
        if (diagnoses.isEmpty)
          _emptyCard(
            icon: Icons.document_scanner_outlined,
            message: l10n.noScansYet,
          )
        else
          ...diagnoses.map((diagnosis) {
            return Card(
      color: _glass,
              child: ListTile(
                leading: Icon(
                  diagnosis.isHealthy
                      ? Icons.check_circle_outline
                      : Icons.warning_amber_outlined,
                  color:
                      diagnosis.isHealthy
                          ? PlantPulseColors.green
                          : PlantPulseColors.warning,
                ),
                title: Text(
                  diagnosis.plantName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${diagnosis.result} • ${(diagnosis.confidence * 100).toStringAsFixed(1)}%',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  _formatDate(diagnosis.createdAt, l10n),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _emptyCard({required IconData icon, required String message}) {
    return Card(
      color: _glass,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, color: PlantPulseColors.muted, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: PlantPulseColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, AppLocalizations l10n) {
    return Card(
      color: _glass,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 36,
              color: PlantPulseColors.danger,
            ),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _refreshDashboard,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return l10n.today;
    if (difference.inDays == 1) return l10n.yesterday;

    return '${date.day}/${date.month}/${date.year}';
  }
}
