import 'package:flutter/material.dart';

import '../../features/plant/user_plant.dart';
import '../../features/theme/models/theme.dart';
import 'meter_row.dart';

/// Card singola pianta — dark botanical.
///
/// Pronta per ricevere callbacks reali (onWater, onDetail) da GardenCubit.
class PlantCard extends StatelessWidget {
  const PlantCard({
    super.key,
    required this.plant,
    this.onWater,
    this.onDetail,
  });

  final UserPlant plant;
  final VoidCallback? onWater;
  final VoidCallback? onDetail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final health = plant.health;
    final healthColor = _healthColor(health);
    final healthLabel = _healthLabel(health);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: LightTheme.surface1,
        border: Border.all(
          color: LightTheme.midGreen.withOpacity(0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header pianta ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              children: [
                // Avatar emoji
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        LightTheme.midGreen.withOpacity(0.4),
                        LightTheme.primary.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      plant.imageUrl,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.name,
                        style: textTheme.titleLarge?.copyWith(
                          color: LightTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        plant.species,
                        style: textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: LightTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: LightTheme.midGreen.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.room_outlined,
                                  size: 11,
                                  color: LightTheme.sage,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  plant.room,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: LightTheme.sage,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Chip stato salute
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: healthColor.withOpacity(0.12),
                    border: Border.all(
                      color: healthColor.withOpacity(0.25),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$health%',
                        style: textTheme.bodyMedium?.copyWith(
                          color: healthColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        healthLabel,
                        style: textTheme.bodyMedium?.copyWith(
                          color: healthColor.withOpacity(0.8),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ───────────────────────────────────────────────────
          Divider(
            height: 1,
            thickness: 1,
            color: LightTheme.midGreen.withOpacity(0.15),
            indent: 16,
            endIndent: 16,
          ),

          // ── Metriche ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              children: [
                MeterRow(label: 'Umidità', value: plant.moisture),
                const SizedBox(height: 10),
                MeterRow(label: 'Luce', value: plant.light),
              ],
            ),
          ),

          // ── Prossima azione ───────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: LightTheme.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: LightTheme.accent.withOpacity(0.15),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.tips_and_updates_outlined,
                  size: 15,
                  color: LightTheme.accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    plant.nextAction,
                    style: textTheme.bodyMedium?.copyWith(
                      color: LightTheme.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Azioni ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onWater ?? () {},
                    icon: const Icon(Icons.water_drop_rounded, size: 16),
                    label: const Text('Annaffia'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(42),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDetail ?? () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(42),
                    ),
                    child: const Text('Dettagli'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _healthColor(int value) {
    if (value >= 85) return LightTheme.accent;
    if (value >= 60) return LightTheme.amber;
    return LightTheme.danger;
  }

  String _healthLabel(int value) {
    if (value >= 85) return 'ottima';
    if (value >= 60) return 'buona';
    return 'cura!';
  }
}
