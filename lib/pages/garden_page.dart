import 'package:flutter/material.dart';
import 'package:plantly_app/features/plant/plant.dart';

import '../widgets/garden/plant_card.dart';

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
                  const SizedBox(
                    height: 280,
                    child: Stack(
                      children: [
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
            ..._plants.map((plant) => PlantCard(plant: plant)),
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
