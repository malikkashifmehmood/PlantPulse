import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_theme.dart';
import '../../core/models/plant.dart';
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
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _scope = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    _searchController.addListener(_onSearchChanged);
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

  Future<void> _loadPlants() async {
    try {
      final plants = _repository!.loadPlants(_scope);

      if (!mounted) return;

      setState(() {
        _plants = plants;
        _error = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Unable to load your plants. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _addPlant() async {
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
        const SnackBar(content: Text('Plant saved successfully.')),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save the plant. Please try again.'),
        ),
      );
    }
  }

  Future<void> _deletePlant(Plant plant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Delete plant?'),
            content: Text(
              'Remove "${plant.name}" and its saved diagnosis history?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final services = AppServicesScope.of(context);

      await _repository!.deletePlant(_scope, plant.id);
      await services.diagnoses.deleteForPlant(_scope, plant.id);
      await _loadPlants();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plant and its diagnosis history deleted.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not complete deletion. Please try again.'),
        ),
      );
      await _loadPlants();
    }
  }

  void _openPlant(Plant plant) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => PlantDetailScreen(plant: plant)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visiblePlants =
        _plants.where((plant) {
          return plant.name.toLowerCase().contains(_searchQuery) ||
              plant.species.toLowerCase().contains(_searchQuery);
        }).toList();

    return PlantPulseScaffold(
      currentIndex: 1,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'My Plants',
              subtitle:
                  '${_plants.length} '
                  '${_plants.length == 1 ? 'plant' : 'plants'} saved',
              trailing: IconButton.filledTonal(
                tooltip: 'Add plant',
                onPressed: _isLoading ? null : _addPlant,
                icon: const Icon(Icons.add_rounded),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search plants',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon:
                    _searchQuery.isEmpty
                        ? null
                        : IconButton(
                          tooltip: 'Clear search',
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
                actionLabel: 'Try again',
                onAction: () {
                  setState(() => _isLoading = true);
                  _loadPlants();
                },
              )
            else if (visiblePlants.isEmpty)
              _MessageState(
                icon: Icons.eco_outlined,
                message:
                    _searchQuery.isNotEmpty
                        ? 'No plants match your search.'
                        : 'Your garden starts here. Add your first plant to keep track of it.',
                actionLabel: _searchQuery.isNotEmpty ? null : 'Add a plant',
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
                      'All ${_plants.length}',
                      style: const TextStyle(
                        color: PlantPulseColors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Tap a plant for details',
                    style: TextStyle(
                      color: PlantPulseColors.muted,
                      fontSize: 12,
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
                    onTap: () => _openPlant(plant),
                    onDelete: () => _deletePlant(plant),
                  ),
                ),
              ),
            ],
          ],
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
    return AlertDialog(
      title: const Text('Add a plant'),
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
                decoration: const InputDecoration(
                  labelText: 'Plant name',
                  hintText: 'e.g. Tomato Roma',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a plant name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _speciesController,
                textCapitalization: TextCapitalization.words,
                maxLength: 60,
                decoration: const InputDecoration(
                  labelText: 'Species',
                  hintText: 'e.g. Tomato',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter the plant species.';
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
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Add plant')),
      ],
    );
  }
}

class _PlantCard extends StatelessWidget {
  const _PlantCard({
    required this.plant,
    required this.onTap,
    required this.onDelete,
  });

  final Plant plant;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final date = plant.createdAt.toLocal();

    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                      'Added $formattedDate',
                      style: const TextStyle(
                        color: PlantPulseColors.muted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'View plant details →',
                      style: TextStyle(
                        color: PlantPulseColors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Delete ${plant.name}',
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
