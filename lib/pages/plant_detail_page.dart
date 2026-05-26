import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/cubits/garden/garden_cubit.dart';
import 'package:plantly_app/cubits/garden/garden_state.dart';
import 'package:plantly_app/cubits/plant_details/plant_details_cubit.dart';
import 'package:plantly_app/cubits/plant_details/plant_details_state.dart';
import 'package:plantly_app/features/plant/plant_species.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:plantly_app/widgets/feedback/snackbar_helper.dart';


class PlantDetailPage extends StatefulWidget {
  const PlantDetailPage({
    super.key,
    required this.initialPlant,
    required this.userId,
  });

  final PlantSpecies initialPlant;
  final String userId;

  @override
  State<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _addToGarden(PlantSpecies plant) async {
    final userId = widget.userId.trim();
    if (userId.isEmpty) {
      SnackBarHelper.showError(context, 'Utente non disponibile. Accedi di nuovo e riprova.');
      return;
    }

    final result = await context.read<GardenCubit>().addPlantFromSpecies(
          userId: userId,
          species: plant,
          nickname: _nicknameController.text,
        );

    if (!mounted) return;

    if (result.isSuccess) {
      SnackBarHelper.showSuccess(context, result.message);
      Navigator.of(context).pop();
    } else {
      SnackBarHelper.showError(context, result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlantDetailsCubit, PlantDetailsState>(
      listener: (context, state) {
        if (state is PlantDetailsFailure) {
          SnackBarHelper.showWarning(context, state.message);
        }
      },
      builder: (context, detailsState) {
        final plant = switch (detailsState) {
          PlantDetailsSuccess() => detailsState.plant,
          PlantDetailsFailure() => detailsState.fallbackPlant ?? widget.initialPlant,
          _ => widget.initialPlant,
        };

        return BlocBuilder<GardenCubit, GardenState>(
          builder: (context, gardenState) {
            return _PlantDetailView(
              plant: plant,
              nicknameController: _nicknameController,
              isAdding: gardenState.isActionInProgress,
              onAdd: () => _addToGarden(plant),
            );
          },
        );
      },
    );
  }
}

class _PlantDetailView extends StatelessWidget {
  const _PlantDetailView({
    required this.plant,
    required this.nicknameController,
    required this.isAdding,
    required this.onAdd,
  });

  final PlantSpecies plant;
  final TextEditingController nicknameController;
  final bool isAdding;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final displayName = plant.commonName.trim().isNotEmpty
        ? plant.commonName.trim()
        : plant.scientificName.trim();

    return Scaffold(
      backgroundColor: LightTheme.canvas,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SizedBox(
          height: 54,
          child: ElevatedButton.icon(
            onPressed: isAdding ? null : onAdd,
            icon: isAdding
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_rounded),
            label: Text(isAdding ? 'Aggiungo…' : 'Aggiungi al mio giardino'),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: LightTheme.surface1,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: _CircleBackButton(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroImage(imageUrl: plant.heroImageUrl),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Text(
                    displayName,
                    style: textTheme.displaySmall?.copyWith(color: LightTheme.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    plant.scientificName.trim().isEmpty
                        ? 'Nome scientifico non disponibile'
                        : plant.scientificName,
                    style: textTheme.bodyLarge?.copyWith(
                      color: LightTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    controller: nicknameController,
                    decoration: const InputDecoration(
                      labelText: 'Nickname opzionale',
                      hintText: 'Es. Monstera del soggiorno',
                      prefixIcon: Icon(Icons.edit_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const SizedBox(height: 18),
                  _InfoCard(
                    title: 'Cura',
                    children: [
                      _InfoRow(
                        icon: Icons.water_drop_rounded,
                        label: 'Acqua',
                        value: _wateringLabel(plant.watering),
                      ),
                      _InfoRow(
                        icon: Icons.wb_sunny_rounded,
                        label: 'Luce',
                        value: _sunlightLabel(plant.sunlight),
                      ),
                      _InfoRow(
                        icon: Icons.home_rounded,
                        label: 'Ambiente',
                        value: _environmentLabel(plant.indoor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoCard(
                    title: 'Sicurezza',
                    children: [
                      _InfoRow(
                        icon: Icons.shield_outlined,
                        label: 'Tossicità',
                        value: _safetyLabel(
                          poisonousToHumans: plant.poisonousToHumans,
                          poisonousToPets: plant.poisonousToPets,
                        ),
                      ),
                    ],
                  ),
                  if (plant.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _InfoNoteCard(
                      title: 'Descrizione',
                      text: plant.description,
                    ),
                  ],
                  const SizedBox(height: 16),
                  const _InfoNoteCard(
                    title: 'Nota',
                    text:
                        'Le informazioni sono indicative e arrivano da Perenual. Potrai rifinire la cura della pianta dopo averla aggiunta al giardino.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _environmentLabel(bool? indoor) {
    if (indoor == true) return 'Adatta soprattutto per interni';
    if (indoor == false) return 'Adatta soprattutto per esterni';
    return 'Ambiente non specificato';
  }

  static String _wateringLabel(String watering) {
    switch (watering.trim().toLowerCase()) {
      case 'frequent':
        return 'Irrigazione frequente';
      case 'average':
        return 'Irrigazione moderata';
      case 'minimum':
        return 'Poca acqua';
      case 'none':
        return 'Nessuna indicazione utile';
      default:
        return watering.trim().isNotEmpty ? watering.trim() : 'Non specificata';
    }
  }

  static String _sunlightLabel(List<String> sunlight) {
    if (sunlight.isEmpty) return 'Non specificata';
    return sunlight.map((value) {
      switch (value.trim().toLowerCase()) {
        case 'full sun':
          return 'Sole pieno';
        case 'part shade':
        case 'partial shade':
          return 'Mezz’ombra';
        case 'full shade':
          return 'Ombra';
        case 'sun-part shade':
          return 'Sole o mezz’ombra';
        default:
          return value.trim();
      }
    }).where((value) => value.isNotEmpty).join(' · ');
  }

  static String _safetyLabel({
    required bool poisonousToHumans,
    required bool poisonousToPets,
  }) {
    if (!poisonousToHumans && !poisonousToPets) {
      return 'Non tossica secondo i dati disponibili';
    }
    if (poisonousToHumans && poisonousToPets) {
      return 'Potenzialmente tossica per persone e animali';
    }
    if (poisonousToHumans) return 'Potenzialmente tossica per le persone';
    return 'Potenzialmente tossica per gli animali';
  }
}

class _CircleBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        decoration: BoxDecoration(
          color: LightTheme.surface1.withOpacity(0.88),
          shape: BoxShape.circle,
          border: Border.all(color: LightTheme.midGreen.withOpacity(0.25)),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: LightTheme.textPrimary,
          size: 18,
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return _placeholder();

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(LightTheme.sage),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            LightTheme.surface2,
            LightTheme.midGreen.withOpacity(0.3),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.local_florist_rounded,
          color: LightTheme.sage,
          size: 72,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LightTheme.surface1,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LightTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleMedium),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: LightTheme.sage, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(color: LightTheme.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(color: LightTheme.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoNoteCard extends StatelessWidget {
  const _InfoNoteCard({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LightTheme.surface2,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LightTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            text,
            style: textTheme.bodyMedium?.copyWith(color: LightTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
