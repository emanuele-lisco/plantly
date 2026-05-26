import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

class MeterRow extends StatelessWidget {
  const MeterRow({super.key, required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final color = _meterColor(value);

    return Row(
      children: [
        SizedBox(
          width: 58,
          child: Text(
            label,
            style: t.bodyMedium?.copyWith(
              color: LightTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: LightTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$value%',
          style: t.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Color _meterColor(int v) {
    if (v >= 75) return LightTheme.success;
    if (v >= 45) return LightTheme.amber;
    return LightTheme.danger;
  }
}