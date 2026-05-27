import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Card mostrata quando l'utente non ha ancora impostato la città nel profilo.
///
/// Non mostra dati meteo né suggerisce irrigazione.
class WeatherLocationMissingCard extends StatelessWidget {
  const WeatherLocationMissingCard({super.key, this.onGoToProfile});

  /// Callback opzionale per navigare al profilo a completare la location.
  final VoidCallback? onGoToProfile;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LightTheme.surface2,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LightTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: LightTheme.amber.withOpacity(0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.location_off_rounded,
              color: LightTheme.amber,
              size: 26,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Posizione non impostata',
            style: t.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Completa il profilo per visualizzare il meteo locale. '
            'Aggiungi la tua città nella sezione Profilo.',
            style: t.bodyMedium,
          ),
          if (onGoToProfile != null) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onGoToProfile,
                icon: const Icon(Icons.person_outline_rounded, size: 18),
                label: const Text('Vai al profilo'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
