import 'package:flutter/material.dart';

import '../../features/theme/models/theme.dart';

class SoilMoistureIndicator extends StatelessWidget {
  const SoilMoistureIndicator({super.key, required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final clamped = percent.clamp(0.0, 100.0);
    final color = _moistureColor(clamped);
    final label = _moistureLabel(clamped);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.water_drop_rounded, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              'Umidità suolo',
              style: textTheme.labelSmall?.copyWith(color: LightTheme.textMuted),
            ),
            const Spacer(),
            Text(
              '${clamped.toStringAsFixed(0)}%',
              style: textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: clamped / 100,
            minHeight: 6,
            backgroundColor: LightTheme.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: LightTheme.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  static Color _moistureColor(double percent) {
    if (percent < 20) return LightTheme.coral;
    if (percent < 40) return LightTheme.amber;
    if (percent <= 75) return LightTheme.water;
    return LightTheme.primary;
  }

  static String _moistureLabel(double percent) {
    if (percent < 20) return 'Suolo secco — necessita irrigazione';
    if (percent < 40) return 'Umidità bassa';
    if (percent <= 75) return 'Umidità ottimale';
    return 'Suolo saturo';
  }
}
