import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Hero card principale nella Home — botanical immersive.
///
/// Mostra il riepilogo stato del giardino con impatto visivo forte.
/// Parametri esposti per futura connessione a GardenSummaryCubit.
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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF12522E),
            Color(0xFF0A3A20),
            Color(0xFF071E13),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        border: Border.all(
          color: LightTheme.midGreen.withOpacity(0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: LightTheme.primary.withOpacity(0.6),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row ──────────────────────────────────────────────────
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
                          decoration: const BoxDecoration(
                            color: LightTheme.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            statusLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: LightTheme.accent,
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
                      style: textTheme.headlineMedium?.copyWith(
                        color: LightTheme.textPrimary,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Salute circolare
              _HealthRing(value: healthScore),
            ],
          ),

          const SizedBox(height: 22),

          // ── Divider ───────────────────────────────────────────────────
          Container(
            height: 1,
            color: LightTheme.midGreen.withOpacity(0.22),
          ),

          const SizedBox(height: 18),

          // ── Bottom stats ──────────────────────────────────────────────
          // Expanded + FittedBox evita l'overflow orizzontale su schermi stretti
          // o con font più grandi: le tre statistiche si dividono lo spazio.
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  icon: Icons.water_drop_rounded,
                  label: 'Da annaffiare',
                  value: alertCount.toString(),
                  color: const Color(0xFF4FC3F7),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeroStat(
                  icon: Icons.wb_sunny_rounded,
                  label: 'In fioritura',
                  value: '2',
                  color: LightTheme.amber,
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
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: LightTheme.accent.withOpacity(0.1),
        border: Border.all(color: LightTheme.accent.withOpacity(0.3), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$value%',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: LightTheme.accent,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          Text(
            'salute',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: LightTheme.textSecondary,
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
    final textTheme = Theme.of(context).textTheme;

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
              color: color.withOpacity(0.12),
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
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: LightTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 10,
                    color: LightTheme.textSecondary,
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
