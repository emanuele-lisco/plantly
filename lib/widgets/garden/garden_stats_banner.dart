import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

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
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LightTheme.surface2,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LightTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                style: t.titleMedium?.copyWith(
                  color: LightTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: LightTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Oggi',
                  style: t.bodyMedium?.copyWith(
                    color: LightTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
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
                  color: LightTheme.success,
                ),
              ),
              Container(width: 1, height: 52, color: LightTheme.border),
              Expanded(
                child: _StatBlock(
                  icon: Icons.water_drop_rounded,
                  label: 'Da annaffiare',
                  value: wateringDue.toString(),
                  color: LightTheme.water,
                ),
              ),
              Container(width: 1, height: 52, color: LightTheme.border),
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
          Row(
            children: [
              Text(
                'Salute giardino',
                style: t.bodyMedium?.copyWith(
                  color: LightTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text(
                '$healthAvg%',
                style: t.bodyMedium?.copyWith(
                  color: LightTheme.primary,
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
              backgroundColor: LightTheme.border,
              valueColor:
              const AlwaysStoppedAnimation<Color>(LightTheme.primary),
              minHeight: 6,
            ),
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
    final t = Theme.of(context).textTheme;
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: t.titleLarge?.copyWith(
            color: LightTheme.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: t.bodyMedium?.copyWith(
            color: LightTheme.textSecondary,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}