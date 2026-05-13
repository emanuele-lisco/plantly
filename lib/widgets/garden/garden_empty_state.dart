import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Stato vuoto della pagina Giardino — dark botanical.
class GardenEmptyState extends StatelessWidget {
  const GardenEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: LightTheme.surface1,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: LightTheme.midGreen.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LightTheme.midGreen.withOpacity(0.15),
            ),
            child: const Icon(
              Icons.local_florist_outlined,
              size: 34,
              color: LightTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Nessuna pianta',
            style: textTheme.titleLarge?.copyWith(
              color: LightTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aggiungi la prima pianta\nal tuo giardino virtuale.',
            style: textTheme.bodyMedium?.copyWith(
              color: LightTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
