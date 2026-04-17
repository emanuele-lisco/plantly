import 'package:flutter/material.dart';

import '../../features/plant/plant.dart';
import '../../features/theme/models/theme.dart';
import 'meter_row.dart';

class PlantCard extends StatelessWidget {
  const PlantCard({super.key, required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF2ECE2)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: LightTheme.primary.withOpacity(0.12),
                ),
                child: Center(
                  child: Text(plant.imageEmoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plant.name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      '${plant.species} • ${plant.room}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: _healthColor(plant.health).withOpacity(0.14),
                ),
                child: Text(
                  '${plant.health}% stato',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _healthColor(plant.health),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MeterRow(label: 'Umidità', value: plant.moisture),
          const SizedBox(height: 10),
          MeterRow(label: 'Luce', value: plant.light),
          const SizedBox(height: 14),
          Text(
            plant.nextAction,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: LightTheme.deepForest,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.water_drop_rounded),
                  label: const Text('Annaffia'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Dettagli cura'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _healthColor(int value) {
    if (value >= 85) return const Color(0xFF2E7D32);
    if (value >= 60) return const Color(0xFF8D6E63);
    return Colors.redAccent;
  }
}