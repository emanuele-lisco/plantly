import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/features/plant/garden_plant.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:plantly_app/cubits/auto_irrigation_settings/auto_irrigation_settings_cubit.dart';
import 'package:plantly_app/cubits/irrigation_control/irrigation_control_cubit.dart';
import 'package:plantly_app/cubits/smart_pot/smart_pot_cubit.dart';
import 'package:plantly_app/repositories/smart_pot_repository.dart';
import 'package:plantly_app/widgets/smart_pot/auto_irrigation_settings_card.dart';
import 'package:plantly_app/widgets/smart_pot/irrigation_control_button.dart';
import 'package:plantly_app/widgets/smart_pot/smart_pot_status_card.dart';

class PlantCard extends StatelessWidget {
  const PlantCard({
    super.key,
    required this.plant,
    required this.userId,
    this.onRemove,
  });

  final GardenPlant plant;
  final String userId;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final nextWateringText = _nextWateringLabel(plant.nextWateringAt);

    return Container(
      decoration: BoxDecoration(
        color: LightTheme.surface2,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LightTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: _PlantImage(imageUrl: plant.imageUrl),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.displayName,
                        style: textTheme.titleMedium?.copyWith(
                          color: LightTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plant.scientificName.isEmpty
                            ? plant.commonName
                            : plant.scientificName,
                        style: textTheme.bodyMedium?.copyWith(
                          color: LightTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _MiniBadge(
                            icon: Icons.water_drop_rounded,
                            label: _wateringLabel(plant.watering),
                            color: LightTheme.water,
                          ),
                          if (plant.indoor != null)
                            _MiniBadge(
                              icon: plant.indoor!
                                  ? Icons.home_rounded
                                  : Icons.park_rounded,
                              label: plant.indoor! ? 'Indoor' : 'Outdoor',
                              color: LightTheme.primary,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: LightTheme.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  color: LightTheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    nextWateringText,
                    style: textTheme.bodyMedium?.copyWith(
                      color: LightTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: BlocProvider(
              create: (context) => SmartPotCubit(
                smartPotRepository: context.read<SmartPotRepository>(),
              )..watchDevice(plant.linkedDeviceId),
              child: const SmartPotStatusCard(),
            ),
          ),
          if (plant.hasLinkedDevice)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: BlocProvider(
                create: (context) => AutoIrrigationSettingsCubit(
                  smartPotRepository: context.read<SmartPotRepository>(),
                )..load(plant.linkedDeviceId),
                child: AutoIrrigationSettingsCard(
                  deviceId: plant.linkedDeviceId,
                  watering: plant.watering,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: BlocProvider(
                    create: (context) => IrrigationControlCubit(
                      smartPotRepository: context.read<SmartPotRepository>(),
                    ),
                    child: IrrigationControlButton(
                      deviceId: plant.linkedDeviceId,
                      requestedBy: userId,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Rimuovi'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(42),
                      foregroundColor: LightTheme.coral,
                      side: BorderSide(
                        color: LightTheme.coral.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _wateringLabel(String watering) {
    switch (watering.trim().toLowerCase()) {
      case 'frequent':
        return 'Frequente';
      case 'average':
        return 'Media';
      case 'minimum':
        return 'Minima';
      case 'none':
        return 'Non indicata';
      default:
        return watering.trim().isEmpty ? 'Non indicata' : watering.trim();
    }
  }

  static String _nextWateringLabel(DateTime? nextWateringAt) {
    if (nextWateringAt == null) {
      return 'Prossima cura non ancora calcolata';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final next = nextWateringAt.toLocal();
    final nextDay = DateTime(next.year, next.month, next.day);
    final difference = nextDay.difference(today).inDays;

    if (difference < 0) return 'Cura in ritardo';
    if (difference == 0) return 'Cura prevista oggi';
    if (difference == 1) return 'Cura prevista domani';
    return 'Cura prevista tra $difference giorni';
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantImage extends StatelessWidget {
  const _PlantImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl.trim();

    if (trimmedUrl.isEmpty) {
      return const _PlantImageFallback();
    }

    if (!trimmedUrl.startsWith('http')) {
      return Container(
        color: LightTheme.sage.withOpacity(0.2),
        alignment: Alignment.center,
        child: Text(
          trimmedUrl,
          style: const TextStyle(fontSize: 28),
        ),
      );
    }

    return Image.network(
      trimmedUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _PlantImageFallback(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: LightTheme.surface3,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: LightTheme.primary,
            ),
          ),
        );
      },
    );
  }
}

class _PlantImageFallback extends StatelessWidget {
  const _PlantImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LightTheme.sage.withOpacity(0.15),
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_florist_rounded,
        color: LightTheme.primary,
        size: 28,
      ),
    );
  }
}