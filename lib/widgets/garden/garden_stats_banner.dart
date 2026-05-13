import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Banner statistiche giardino — sostituisce GardenOrbPreview.
///
/// Mostra un riepilogo visivo compatto dello stato generale.
/// Dati statici → pronti per GardenCubit.
class GardenStatsBanner extends StatelessWidget {
  const GardenStatsBanner({
    super.key,
    this.healthAvg = 87,
    this.wateringDue = 1,
    this.sunExposure = 78,
  });

  final int healthAvg;
  final int wateringDue;
  final int sunExposure;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF122A1C),
            Color(0xFF0D2215),
          ],
        ),
        border: Border.all(
          color: LightTheme.midGreen.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
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
              Text(
                'Vista d\'insieme',
                style: textTheme.titleMedium?.copyWith(
                  color: LightTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                'Oggi',
                style: textTheme.bodyMedium?.copyWith(
                  color: LightTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatBlock(
                  icon: Icons.favorite_rounded,
                  label: 'Salute media',
                  value: '$healthAvg%',
                  color: LightTheme.accent,
                ),
              ),
              Container(
                width: 1,
                height: 52,
                color: LightTheme.midGreen.withOpacity(0.2),
              ),
              Expanded(
                child: _StatBlock(
                  icon: Icons.water_drop_rounded,
                  label: 'Da annaffiare',
                  value: wateringDue.toString(),
                  color: const Color(0xFF4FC3F7),
                ),
              ),
              Container(
                width: 1,
                height: 52,
                color: LightTheme.midGreen.withOpacity(0.2),
              ),
              Expanded(
                child: _StatBlock(
                  icon: Icons.wb_sunny_rounded,
                  label: 'Esposizione',
                  value: '$sunExposure%',
                  color: LightTheme.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Health bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Salute giardino',
                    style: textTheme.bodyMedium?.copyWith(
                      color: LightTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$healthAvg%',
                    style: textTheme.bodyMedium?.copyWith(
                      color: LightTheme.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: healthAvg / 100,
                  backgroundColor: LightTheme.midGreen.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    LightTheme.accent,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
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

    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            color: LightTheme.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: LightTheme.textSecondary,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
