import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_theme.dart';
import '../../core/models/plant.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/plantpulse_scaffold.dart';
import 'data/plant_repository.dart';
import 'plant_detail_screen.dart';

class PlantsScreen extends StatefulWidget {
  const PlantsScreen({super.key});

  @override
  State<PlantsScreen> createState() => _PlantsScreenState();
}

class _PlantsScreenState extends State<PlantsScreen> {
  final _searchController = TextEditingController();

  PlantRepository? _repository;
  late final String _scope;

  List<Plant> _plants = [];
  final Set<String> _deletingPlantIds = {};

  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _scope = _resolveScope();
    _searchController.addListener(_onSearchChanged);
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

    if (_repository == null) {
      _repository = AppServicesScope.of(context).plants;
      _loadPlants();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (!mounted) return;

    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  Future<void> _loadPlants({bool showLoading = false}) async {
    final repository = _repository;
    if (repository == null) return;

    if (showLoading && mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final plants = repository.loadPlants(_scope);

      if (!mounted) return;

      setState(() {
        _plants = plants;
        _error = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = AppLocalizations.of(context).plantsLoadFailed;
        _isLoading = false;
      });
    }
  }

  Future<void> _addPlant() async {
    if (_isLoading) return;

    final result = await showDialog<Plant>(
      context: context,
      builder: (_) => const _AddPlantDialog(),
    );

    if (result == null || !mounted) return;

    try {
      await _repository!.savePlant(_scope, result);
      await _loadPlants();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).plantsSavedSuccessfully),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).plantsSaveFailed)),
      );
    }
  }

  Future<void> _deletePlant(Plant plant) async {
    if (_deletingPlantIds.contains(plant.id)) return;

    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(l10n.plantsDeleteTitle),
            content: Text(l10n.plantsDeleteConfirmation(plant.name)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.plantsCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(l10n.plantsDelete),
              ),
            ],
          ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deletingPlantIds.add(plant.id));

    try {
      final services = AppServicesScope.of(context);

      // Remove related records before deleting the plant itself.
      // These local-storage operations are not transactional.
      await services.diagnoses.deleteForPlant(_scope, plant.id);

      await services.treatmentProgress.deleteForPlant(
        scope: _scope,
        plantId: plant.id,
      );

      await _repository!.deletePlant(_scope, plant.id);

      await _loadPlants();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).plantsDeletedSuccessfully),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      await _loadPlants();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).plantsDeleteFailed),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _deletingPlantIds.remove(plant.id));
      }
    }
  }

  Future<void> _openPlant(Plant plant) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => PlantDetailScreen(plant: plant)),
    );

    if (mounted) {
      await _loadPlants();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final visiblePlants =
        _plants.where((plant) {
          return plant.name.toLowerCase().contains(_searchQuery) ||
              plant.species.toLowerCase().contains(_searchQuery);
        }).toList();

    return PlantPulseScaffold(
      currentIndex: 1,
      child: RefreshIndicator(
        onRefresh: _loadPlants,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: l10n.plantsTitle,
                subtitle: l10n.plantsSavedCount(_plants.length),
                trailing: IconButton.filledTonal(
                  tooltip: l10n.plantsAddPlantTooltip,
                  onPressed: _isLoading ? null : _addPlant,
                  icon: const Icon(Icons.add_rounded),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.plantsSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon:
                      _searchQuery.isEmpty
                          ? null
                          : IconButton(
                            tooltip: l10n.plantsClearSearch,
                            onPressed: _searchController.clear,
                            icon: const Icon(Icons.close_rounded),
                          ),
                ),
              ),
              const SizedBox(height: 18),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(36),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_error != null)
                _MessageState(
                  icon: Icons.cloud_off_rounded,
                  message: _error!,
                  actionLabel: l10n.plantsTryAgain,
                  onAction: () => _loadPlants(showLoading: true),
                )
              else if (visiblePlants.isEmpty)
                _MessageState(
                  icon: Icons.eco_outlined,
                  message:
                      _searchQuery.isNotEmpty
                          ? l10n.plantsNoSearchMatches
                          : l10n.plantsEmptyGarden,
                  actionLabel:
                      _searchQuery.isNotEmpty ? null : l10n.plantsAddFirst,
                  onAction: _searchQuery.isNotEmpty ? null : _addPlant,
                )
              else ...[
                Row(
                  children: [
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
                        l10n.plantsAllCount(_plants.length),
                        style: const TextStyle(
                          color: PlantPulseColors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        l10n.plantsTapForDetails,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          color: PlantPulseColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...visiblePlants.map(
                  (plant) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PlantCard(
                      plant: plant,
                      isDeleting: _deletingPlantIds.contains(plant.id),
                      onTap: () => _openPlant(plant),
                      onDelete: () => _deletePlant(plant),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AddPlantDialog extends StatefulWidget {
  const _AddPlantDialog();

  @override
  State<_AddPlantDialog> createState() => _AddPlantDialogState();
}

class _AddPlantDialogState extends State<_AddPlantDialog> {
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();

    Navigator.of(context).pop(
      Plant(
        id: now.microsecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        species: _speciesController.text.trim(),
        createdAt: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.plantsAddDialogTitle),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                maxLength: 60,
                decoration: InputDecoration(
                  labelText: l10n.plantsNameLabel,
                  hintText: l10n.plantsNameHint,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.plantsNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _speciesController,
                textCapitalization: TextCapitalization.words,
                maxLength: 60,
                decoration: InputDecoration(
                  labelText: l10n.plantsSpeciesLabel,
                  hintText: l10n.plantsSpeciesHint,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.plantsSpeciesRequired;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.plantsCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.plantsAddFirst)),
      ],
    );
  }
}

class _PlantCard extends StatelessWidget {
  const _PlantCard({
    required this.plant,
    required this.isDeleting,
    required this.onTap,
    required this.onDelete,
  });

  final Plant plant;
  final bool isDeleting;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = plant.createdAt.toLocal();

    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isDeleting ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const PlantIcon(size: 54),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plant.species,
                      style: const TextStyle(
                        color: PlantPulseColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.plantsAddedDate(formattedDate),
                      style: const TextStyle(
                        color: PlantPulseColors.muted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      l10n.plantsViewDetails,
                      style: const TextStyle(
                        color: PlantPulseColors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDeleting)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                IconButton(
                  tooltip: l10n.plantsDeleteTooltip(plant.name),
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: PlantPulseColors.muted,
                  ),
                ),
            ],
          ),
        ),
      ),
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
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            Icon(icon, size: 48, color: PlantPulseColors.green),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: PlantPulseColors.muted,
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
