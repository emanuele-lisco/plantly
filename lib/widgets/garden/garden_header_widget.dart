import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Header della pagina Giardino — dark botanical.
///
/// [plantCount] collegabile a un futuro GardenCubit.
class GardenHeaderWidget extends StatelessWidget {
  const GardenHeaderWidget({
    super.key,
    this.plantCount = 0,
  });

  final int plantCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'my garden',
                style: textTheme.bodyMedium?.copyWith(
                  color: LightTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Il mio giardino',
                style: textTheme.displaySmall?.copyWith(
                  color: LightTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: LightTheme.surface2,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: LightTheme.midGreen.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.local_florist_rounded,
                size: 15,
                color: LightTheme.accent,
              ),
              const SizedBox(width: 6),
              Text(
                '$plantCount piante',
                style: textTheme.bodyMedium?.copyWith(
                  color: LightTheme.textPrimary,
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
