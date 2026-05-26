import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

class GardenHeaderWidget extends StatelessWidget {
  const GardenHeaderWidget({super.key, this.plantCount = 0});
  final int plantCount;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plantly garden',
                style: t.bodyMedium?.copyWith(
                  color: LightTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Il mio giardino',
                style: t.displaySmall?.copyWith(color: LightTheme.textPrimary),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: LightTheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: LightTheme.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.local_florist_rounded,
                size: 15,
                color: LightTheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '$plantCount piante',
                style: t.bodyMedium?.copyWith(
                  color: LightTheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}