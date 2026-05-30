import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Tile metrica meteo — versione compatta per griglia 2×2.
///
/// Mostra icona Material (NO emoji), label, valore.
/// Usa un background tinto con il colore semantico dell'accento.
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: LightTheme.surface2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LightTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: t.bodySmall?.copyWith(color: LightTheme.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: t.titleSmall?.copyWith(
                    color: LightTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
