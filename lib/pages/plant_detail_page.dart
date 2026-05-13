import 'package:flutter/material.dart';
import 'package:plantly_app/features/plant/plant_species.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:plantly_app/widgets/search/plant_info_badge.dart';

/// Pagina dettaglio di una specie vegetale.
///
/// È una pagina puramente presentazionale: riceve [PlantSpecies] come
/// argomento di navigazione e non accede ad alcun cubit o repository.
/// La logica di fetching dettaglio (se necessaria in futuro) va nel cubit.
class PlantDetailPage extends StatelessWidget {
  const PlantDetailPage({super.key, required this.plant});

  final PlantSpecies plant;

  /// Route helper per una navigazione tipizzata e sicura.
  static Route<void> route(PlantSpecies plant) {
    return MaterialPageRoute(
      builder: (_) => PlantDetailPage(plant: plant),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: LightTheme.canvas,
      body: CustomScrollView(
        slivers: [
          // ── Hero image con AppBar fluttuante ──────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: LightTheme.surface1,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: _CircleBackButton(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroImage(imageUrl: plant.imageUrl),
            ),
          ),

          // ── Contenuto ────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Nomi ─────────────────────────────────────────────
                Text(
                  plant.commonName.isNotEmpty
                      ? plant.commonName
                      : plant.scientificName,
                  style: textTheme.displaySmall?.copyWith(
                    color: LightTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plant.scientificName,
                  style: textTheme.bodyLarge?.copyWith(
                    color: LightTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 16),

                // ── Badge top ─────────────────────────────────────────
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _topBadges(),
                ),

                const SizedBox(height: 30),

                // ── Sezione: Cura ──────────────────────────────────────
                _SectionLabel(label: 'Cura'),
                const SizedBox(height: 12),

                PlantDetailRow(
                  icon: Icons.water_drop_rounded,
                  color: LightTheme.water,
                  label: 'Annaffiatura',
                  value: _localizeWatering(plant.watering),
                ),

                const SizedBox(height: 10),

                PlantDetailRow(
                  icon: Icons.wb_sunny_rounded,
                  color: LightTheme.amber,
                  label: 'Esposizione alla luce',
                  value: plant.sunlight.isNotEmpty
                      ? plant.sunlight
                      .map(_localizeSunlight)
                      .join(' · ')
                      : 'Non specificata',
                ),

                const SizedBox(height: 30),

                // ── Sezione: Ambiente ──────────────────────────────────
                _SectionLabel(label: 'Ambiente'),
                const SizedBox(height: 12),

                PlantBoolRow(
                  icon: Icons.home_rounded,
                  label: 'Adatta per interni',
                  value: plant.indoor,
                  trueLabel: 'Indoor',
                  falseLabel: 'Outdoor',
                ),

                const SizedBox(height: 30),

                // ── Sezione: Sicurezza ─────────────────────────────────
                _SectionLabel(label: 'Sicurezza'),
                const SizedBox(height: 12),

                PlantBoolRow(
                  icon: Icons.person_rounded,
                  label: 'Velenosa per gli esseri umani',
                  value: plant.poisonousToHumans,
                  trueLabel: 'Sì, tossica',
                  falseLabel: 'Non tossica',
                  trueIsDangerous: true,
                ),

                const SizedBox(height: 10),

                PlantBoolRow(
                  icon: Icons.pets_rounded,
                  label: 'Velenosa per gli animali',
                  value: plant.poisonousToPets,
                  trueLabel: 'Sì, tossica',
                  falseLabel: 'Non tossica',
                  trueIsDangerous: true,
                ),

                // Avviso tossicità se necessario
                if (plant.poisonousToHumans || plant.poisonousToPets) ...[
                  const SizedBox(height: 16),
                  _ToxicityWarning(
                    humans: plant.poisonousToHumans,
                    pets: plant.poisonousToPets,
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _topBadges() {
    return [
      PlantInfoBadge(
        type: plant.indoor ? PlantBadgeType.indoor : PlantBadgeType.outdoor,
        label: plant.indoor ? 'Indoor' : 'Outdoor',
      ),
      if (plant.watering.isNotEmpty)
        PlantInfoBadge(
          type: PlantBadgeType.watering,
          label: _localizeWatering(plant.watering),
        ),
      if (plant.sunlight.isNotEmpty)
        PlantInfoBadge(
          type: PlantBadgeType.sunlight,
          label: _localizeSunlight(plant.sunlight.first),
        ),
      if (!plant.poisonousToHumans && !plant.poisonousToPets)
        const PlantInfoBadge(
          type: PlantBadgeType.safe,
          label: 'Non tossica',
        ),
      if (plant.poisonousToHumans || plant.poisonousToPets)
        const PlantInfoBadge(
          type: PlantBadgeType.poisonous,
          label: 'Tossica',
        ),
    ];
  }

  String _localizeWatering(String w) {
    switch (w.toLowerCase()) {
      case 'frequent':
        return 'Frequente';
      case 'average':
        return 'Media';
      case 'minimum':
        return 'Minima';
      case 'none':
        return 'Nessuna';
      default:
        return w.isNotEmpty ? w : 'Non specificata';
    }
  }

  String _localizeSunlight(String s) {
    switch (s.toLowerCase()) {
      case 'full sun':
        return 'Sole pieno';
      case 'part shade':
      case 'partial shade':
        return 'Mezz\'ombra';
      case 'full shade':
        return 'Ombra';
      case 'sun-part shade':
        return 'Sole / mezz\'ombra';
      default:
        return s.isNotEmpty ? s : 'Non specificata';
    }
  }
}

// ── Subwidget locali ──────────────────────────────────────────────────────────

class _CircleBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        decoration: BoxDecoration(
          color: LightTheme.surface1.withOpacity(0.88),
          shape: BoxShape.circle,
          border: Border.all(
            color: LightTheme.midGreen.withOpacity(0.25),
          ),
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
        return _shimmer();
      },
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _shimmer() {
    return Container(
      color: LightTheme.surface2,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(LightTheme.sage),
        ),
      ),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: LightTheme.textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Divider(
            color: LightTheme.midGreen.withOpacity(0.2),
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _ToxicityWarning extends StatelessWidget {
  const _ToxicityWarning({
    required this.humans,
    required this.pets,
  });

  final bool humans;
  final bool pets;

  @override
  Widget build(BuildContext context) {
    final who = [
      if (humans) 'persone',
      if (pets) 'animali domestici',
    ].join(' e ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LightTheme.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LightTheme.danger.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: LightTheme.danger,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Questa pianta può essere tossica per $who. '
                  'Tienila fuori dalla portata.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: LightTheme.danger.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}