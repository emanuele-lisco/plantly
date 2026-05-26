import 'package:flutter/material.dart';

import '../../features/theme/models/theme.dart';

class LightIndicator extends StatelessWidget {
  const LightIndicator({super.key, required this.lux});

  final double lux;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final label = _luxLabel(lux);
    final color = _luxColor(lux);

    return Row(
      children: [
        Icon(Icons.wb_sunny_rounded, size: 15, color: color),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Luce',
                style: textTheme.labelSmall?.copyWith(color: LightTheme.textMuted),
              ),
              const SizedBox(height: 1),
              RichText(
                text: TextSpan(
                  style: textTheme.bodySmall?.copyWith(color: LightTheme.textSecondary),
                  children: [
                    TextSpan(
                      text: '${lux.toStringAsFixed(0)} lux',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(text: '  ·  $label'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Color _luxColor(double lux) {
    if (lux < 500) return LightTheme.textMuted;
    if (lux < 2000) return LightTheme.amber;
    return LightTheme.primary;
  }

  static String _luxLabel(double lux) {
    if (lux < 200) return 'Ombra profonda';
    if (lux < 500) return 'Luce scarsa';
    if (lux < 2000) return 'Luce indiretta';
    if (lux < 10000) return 'Buona luminosità';
    return 'Sole diretto';
  }
}
