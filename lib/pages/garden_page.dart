import 'package:flutter/material.dart';
import 'package:plantly_app/features/plant/plant.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

class GardenPage extends StatelessWidget {
  const GardenPage({super.key});

  static const _plants = [
    Plant(
      id: '1',
      name: 'Monstera',
      species: 'Monstera deliciosa',
      room: 'Soggiorno',
      moisture: 36,
      light: 78,
      health: 88,
      nextAction: 'Annaffiare entro domani',
      imageEmoji: '🌿',
    ),
    Plant(
      id: '2',
      name: 'Ficus',
      species: 'Ficus lyrata',
      room: 'Ingresso',
      moisture: 62,
      light: 64,
      health: 81,
      nextAction: 'Ruotare verso la luce',
      imageEmoji: '🪴',
    ),
    Plant(
      id: '3',
      name: 'Lavanda',
      species: 'Lavandula',
      room: 'Balcone',
      moisture: 54,
      light: 91,
      health: 93,
      nextAction: 'Ottima esposizione stagionale',
      imageEmoji: '💜',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE6E0D3),
            Color(0xFFF7F4EE),
            Color(0xFFEFE8DB),
          ],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            Text('Giardino virtuale', style: textTheme.displaySmall),
            const SizedBox(height: 8),
            Text(
              'Uno spazio più immersivo, morbido e leggibile. Non una lista piatta, ma carte con profondità.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFDDD1BC),
                    Color(0xFFF4ECDD),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 26,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vista immersiva', style: textTheme.titleLarge),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 280,
                    child: Stack(
                      children: const [
                        _PlantOrb(left: 8, top: 96, size: 104, emoji: '🌿'),
                        _PlantOrb(left: 118, top: 34, size: 136, emoji: '🪴'),
                        _PlantOrb(left: 238, top: 120, size: 94, emoji: '💜'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ..._plants.map((plant) => _PlantCard(plant: plant)),
            const SizedBox(height: 10),
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

class _PlantOrb extends StatelessWidget {
  const _PlantOrb({
    required this.left,
    required this.top,
    required this.size,
    required this.emoji,
  });

  final double left;
  final double top;
  final double size;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFE8DCC6)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.09),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(fontSize: size * 0.34),
          ),
        ),
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  const _PlantCard({required this.plant});

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
          _MeterRow(label: 'Umidità', value: plant.moisture),
          const SizedBox(height: 10),
          _MeterRow(label: 'Luce', value: plant.light),
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

class _MeterRow extends StatelessWidget {
  const _MeterRow({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const Spacer(),
            Text('$value%', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: value / 100,
            backgroundColor: Colors.black.withOpacity(0.06),
            valueColor: AlwaysStoppedAnimation<Color>(
              value >= 70 ? LightTheme.primary : const Color(0xFFB78A62),
            ),
          ),
        ),
      ],
    );
  }
}
