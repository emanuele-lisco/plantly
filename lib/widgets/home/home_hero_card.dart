import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({
    super.key,
    this.plantCount = 4,
    this.healthScore = 82,
    this.alertCount = 1,
    this.statusLabel = 'Giardino in salute',
  });

  final int plantCount;
  final int healthScore;
  final int alertCount;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LightTheme.heroGradient,
        boxShadow: [
          BoxShadow(
            color: LightTheme.primaryDark.withOpacity(0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: LightTheme.sage,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            statusLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.bodyMedium?.copyWith(
                              color: LightTheme.sage,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$plantCount piante\nnel tuo giardino',
                      style: t.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _HealthRing(value: healthScore),
            ],
          ),

          const SizedBox(height: 22),
          Container(height: 1, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  icon: Icons.water_drop_rounded,
                  label: 'Da annaffiare',
                  value: alertCount.toString(),
                  color: const Color(0xFF7DD3FC),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeroStat(
                  icon: Icons.wb_sunny_rounded,
                  label: 'In fioritura',
                  value: '2',
                  color: const Color(0xFFFCD34D),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeroStat(
                  icon: Icons.eco_rounded,
                  label: 'Nuovi',
                  value: '1',
                  color: LightTheme.sage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthRing extends StatelessWidget {
  const _HealthRing({required this.value});
  final int value;

  @override
  Widget build(BuildContext context) {
    final color = value >= 75
        ? LightTheme.sage
        : value >= 50
        ? LightTheme.amber
        : LightTheme.coral;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$value%',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          Text(
            'salute',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 82),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  style: t.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  style: t.bodyMedium?.copyWith(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}