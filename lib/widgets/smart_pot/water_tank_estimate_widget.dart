import 'package:flutter/material.dart';

import '../../features/theme/models/theme.dart';

class WaterTankEstimateWidget extends StatelessWidget {
  const WaterTankEstimateWidget({
    super.key,
    required this.waterRemainingPercent,
    this.waterRemainingMl,
  });

  final double waterRemainingPercent;
  final double? waterRemainingMl;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final clamped = waterRemainingPercent.clamp(0.0, 100.0);
    final color = _tankColor(clamped);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.water_rounded, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              'Acqua serbatoio',
              style: textTheme.labelSmall?.copyWith(color: LightTheme.textMuted),
            ),
            const Spacer(),
            Text(
              _percentLabel(clamped, waterRemainingMl),
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
        if (clamped < 20) ...[
          const SizedBox(height: 3),
          Text(
            'Serbatoio quasi vuoto — riempilo presto.',
            style: textTheme.bodySmall?.copyWith(
              color: LightTheme.coral,
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }

  static Color _tankColor(double percent) {
    if (percent < 20) return LightTheme.coral;
    if (percent < 40) return LightTheme.amber;
    return LightTheme.water;
  }

  static String _percentLabel(double percent, double? ml) {
    final pct = '${percent.toStringAsFixed(0)}%';
    if (ml != null && ml > 0) return '$pct (${ml.toStringAsFixed(0)} ml)';
    return pct;
  }
}
