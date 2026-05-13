import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Card "In arrivo" — dark botanical.
class SearchComingSoonCard extends StatelessWidget {
  const SearchComingSoonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF122A1C),
            Color(0xFF0D2215),
          ],
        ),
        border: Border.all(
          color: LightTheme.midGreen.withOpacity(0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: LightTheme.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: LightTheme.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: LightTheme.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: LightTheme.accent.withOpacity(0.25),
                  ),
                ),
                child: Text(
                  'In arrivo',
                  style: textTheme.bodyMedium?.copyWith(
                    color: LightTheme.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Ricerca intelligente',
            style: textTheme.headlineMedium?.copyWith(
              color: LightTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cerca qualsiasi pianta per nome, specie o caratteristica. '
            'Disponibile nelle prossime versioni di Plantly.',
            style: textTheme.bodyLarge?.copyWith(
              color: LightTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ...[
            'Ricerca per nome e specie',
            'Filtri per ambiente e luce',
            'Schede dettaglio con consigli di cura',
            'Compatibilità con il vaso smart',
          ].map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: LightTheme.accent.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: LightTheme.accent.withOpacity(0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: LightTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    feature,
                    style: textTheme.bodyMedium?.copyWith(
                      color: LightTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
