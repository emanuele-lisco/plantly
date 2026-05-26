import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import '../../features/strenght_enum.dart';

/// Indicatore forza password — light botanical.
class PasswordStrength extends StatelessWidget {
  const PasswordStrength({super.key, required this.strength});

  final Strength strength;

  static const _barWidth = 58.0;
  static const _barHeight = 6.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (bars, color, label) = _config(strength);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'FORZA PASSWORD',
                style: textTheme.bodyMedium?.copyWith(
                  color: LightTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: 10),
              if (label.isNotEmpty)
                Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(4, (i) {
              final filled = i < bars;
              return Padding(
                padding: const EdgeInsets.only(right: 5),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: _barHeight,
                  width: _barWidth,
                  decoration: BoxDecoration(
                    color: filled ? color : LightTheme.border,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: filled
                        ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : [],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  (int bars, Color color, String label) _config(Strength s) {
    return switch (s) {
      Strength.empty => (0, LightTheme.textMuted, ''),
      Strength.weak => (1, LightTheme.danger, 'Debole'),
      Strength.medium => (2, LightTheme.amber, 'Media'),
      Strength.strong => (4, LightTheme.accent, 'Forte'),
    };
  }
}