import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Anteprima visiva delle piante come orbs — dark botanical.
///
/// Mantenuto per compatibilità. Nella GardenPage è stato sostituito
/// da GardenStatsBanner ma il widget rimane disponibile.
class GardenOrbPreview extends StatelessWidget {
  const GardenOrbPreview({
    super.key,
    required this.emojis,
  });

  final List<String> emojis;

  static const _positions = [
    _OrbPosition(left: 8, top: 80, size: 110),
    _OrbPosition(left: 112, top: 20, size: 140),
    _OrbPosition(left: 242, top: 90, size: 100),
    _OrbPosition(left: 30, top: 160, size: 88),
    _OrbPosition(left: 210, top: 170, size: 78),
  ];

  @override
  Widget build(BuildContext context) {
    final count = emojis.length.clamp(0, _positions.length);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF122A1C),
            Color(0xFF0D2215),
          ],
        ),
        border: Border.all(
          color: LightTheme.midGreen.withOpacity(0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vista d\'insieme',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: LightTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: count == 0
                ? const _EmptyOrbState()
                : Stack(
                    children: [
                      for (int i = 0; i < count; i++)
                        _PlantOrb(
                          position: _positions[i],
                          emoji: emojis[i],
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _OrbPosition {
  const _OrbPosition(
      {required this.left, required this.top, required this.size});
  final double left;
  final double top;
  final double size;
}

class _PlantOrb extends StatelessWidget {
  const _PlantOrb({required this.position, required this.emoji});
  final _OrbPosition position;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.left,
      top: position.top,
      child: Container(
        width: position.size,
        height: position.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              LightTheme.midGreen.withOpacity(0.5),
              LightTheme.primary.withOpacity(0.9),
            ],
          ),
          border: Border.all(
            color: LightTheme.midGreen.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(emoji, style: TextStyle(fontSize: position.size * 0.35)),
        ),
      ),
    );
  }
}

class _EmptyOrbState extends StatelessWidget {
  const _EmptyOrbState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_florist_outlined,
              size: 48, color: LightTheme.textMuted),
          const SizedBox(height: 12),
          Text(
            'Nessuna pianta ancora',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: LightTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
