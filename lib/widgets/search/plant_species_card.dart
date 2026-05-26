import 'package:flutter/material.dart';
import 'package:plantly_app/features/plant/plant_species.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:plantly_app/widgets/search/plant_info_badge.dart';

class PlantSpeciesCard extends StatelessWidget {
  const PlantSpeciesCard({
    super.key,
    required this.plant,
    required this.onTap,
  });

  final PlantSpecies plant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: LightTheme.surface1,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: LightTheme.midGreen.withOpacity(0.20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: _PlantImage(imageUrl: plant.heroImageUrl),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.commonName.isNotEmpty
                        ? plant.commonName
                        : plant.scientificName,
                    style: textTheme.titleMedium?.copyWith(
                      color: LightTheme.textPrimary,
                      fontSize: 13,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plant.scientificName,
                    style: textTheme.labelSmall?.copyWith(
                      color: LightTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: _buildBadges(plant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBadges(PlantSpecies p) {
    final badges = <Widget>[
      if (plant.indoor != null)
        PlantInfoBadge(
          type: plant.indoor! ? PlantBadgeType.indoor : PlantBadgeType.outdoor,
          label: plant.indoor! ? 'Indoor' : 'Outdoor',
        ),
    ];

    if (p.watering.isNotEmpty) {
      badges.add(
        PlantInfoBadge(
          type: PlantBadgeType.watering,
          label: _shortenWatering(p.watering),
          compact: true,
        ),
      );
    }

    if (p.poisonousToHumans || p.poisonousToPets) {
      badges.add(
        const PlantInfoBadge(
          type: PlantBadgeType.poisonous,
          label: 'Tossica',
          compact: true,
        ),
      );
    }

    return badges;
  }

  String _shortenWatering(String w) {
    switch (w.toLowerCase()) {
      case 'frequent':
        return 'Freq.';
      case 'average':
        return 'Media';
      case 'minimum':
        return 'Min.';
      case 'none':
        return 'Nessuna';
      default:
        return w.length > 8 ? '${w.substring(0, 7)}…' : w;
    }
  }
}

class _PlantImage extends StatelessWidget {
  const _PlantImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return _placeholder();

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return _loadingShimmer();
      },
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _loadingShimmer() {
    return Container(
      color: LightTheme.surface2,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(LightTheme.sage),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: LightTheme.surface2,
      child: const Center(
        child: Icon(
          Icons.local_florist_rounded,
          color: LightTheme.midGreen,
          size: 40,
        ),
      ),
    );
  }
}