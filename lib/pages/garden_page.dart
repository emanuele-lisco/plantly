import 'package:flutter/material.dart';
import 'package:plantly_app/features/plant/user_plant.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:plantly_app/widgets/garden/garden_header_widget.dart';
import 'package:plantly_app/widgets/garden/garden_stats_banner.dart';
import 'package:plantly_app/widgets/garden/plant_card.dart';

/// Pagina Giardino virtuale — dark botanical.
///
/// Struttura leggera: ogni sezione è un widget separato e riutilizzabile.
/// Dati statici → sostituibili con BlocBuilder + GardenCubit.
class GardenPage extends StatelessWidget {
  const GardenPage({super.key});

  static const _plants = [
    UserPlant(
      id: '1',
      name: 'Monstera',
      species: 'Monstera deliciosa',
      room: 'Soggiorno',
      moisture: 36,
      light: 78,
      health: 88,
      nextAction: 'Annaffiare entro domani',
      imageUrl: '🌿', speciesId: '',
    ),
    UserPlant(
      id: '2',
      name: 'Ficus',
      species: 'Ficus lyrata',
      room: 'Ingresso',
      moisture: 62,
      light: 64,
      health: 81,
      nextAction: 'Ruotare verso la luce',
      imageUrl: '🪴', speciesId: '',
    ),
    UserPlant(
      id: '3',
      name: 'Lavanda',
      species: 'Lavandula',
      room: 'Balcone',
      moisture: 54,
      light: 91,
      health: 93,
      nextAction: 'Ottima esposizione stagionale',
      imageUrl: '💜', speciesId: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF091A10),
            LightTheme.canvas,
          ],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: [
            // ── Header ──────────────────────────────────────────────────
            GardenHeaderWidget(plantCount: _plants.length),

            const SizedBox(height: 20),

            // ── Stats banner ─────────────────────────────────────────────
            const GardenStatsBanner(),

            const SizedBox(height: 24),

            // ── Lista piante ─────────────────────────────────────────────
            Row(
              children: [
                Text('Le tue piante', style: textTheme.titleLarge),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: LightTheme.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_plants.length} totali',
                    style: textTheme.bodyMedium?.copyWith(
                      color: LightTheme.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (final plant in _plants) PlantCard(plant: plant),

            const SizedBox(height: 6),

            // ── Pulsante aggiungi ─────────────────────────────────────────
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded),
              label: const Text('Aggiungi una pianta'),
            ),
          ],
        ),
      ),
    );
  }
}
