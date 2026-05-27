import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Tile riutilizzabile per una singola metrica meteo (es. temperatura, min/max).
class WeatherMetricTile extends StatelessWidget {
  const WeatherMetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accent = LightTheme.primary,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: t.bodySmall?.copyWith(color: LightTheme.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: t.titleMedium?.copyWith(color: LightTheme.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
