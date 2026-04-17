import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Pagina di ricerca piante — placeholder production-ready.
///
/// Questa pagina è predisposta per la futura funzionalità di ricerca piante.
/// Al momento non contiene logica di ricerca reale.
///
/// Quando la feature verrà implementata, sarà sufficiente:
/// - aggiungere un `PlantSearchCubit` con il relativo stato
/// - collegare `PlantRepository` al cubit
/// - sostituire il corpo statico con un `BlocBuilder`
/// - non sarà necessario modificare la navigazione
class PlantSearchPage extends StatelessWidget {
  const PlantSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFECE6D9),
            Color(0xFFF7F4EE),
          ],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            Text('Cerca una pianta', style: textTheme.displaySmall),
            const SizedBox(height: 8),
            Text(
              'Trova informazioni su specie, cura e compatibilità.',
              style: textTheme.bodyLarge?.copyWith(
                color: LightTheme.deepForest.withOpacity(0.65),
              ),
            ),
            const SizedBox(height: 20),

            // Campo di ricerca — placeholder visivo, non ancora funzionale.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.82),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: LightTheme.deepForest.withOpacity(0.4),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Nome, specie, o stanza…',
                    style: textTheme.bodyLarge?.copyWith(
                      color: LightTheme.deepForest.withOpacity(0.38),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Sezione "in arrivo" — segnale visivo chiaro che la feature è pending.
            _ComingSoonCard(textTheme: textTheme),

            const SizedBox(height: 20),

            // Categorie suggerite — UI statica, prefigurano la struttura futura.
            Text('Categorie', style: textTheme.titleLarge),
            const SizedBox(height: 12),
            const Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _CategoryChip(label: 'Piante da interno', icon: Icons.home_outlined),
                _CategoryChip(label: 'Succulente', icon: Icons.wb_sunny_outlined),
                _CategoryChip(label: 'Erbe aromatiche', icon: Icons.eco_outlined),
                _CategoryChip(label: 'Fioriture stagionali', icon: Icons.local_florist_outlined),
                _CategoryChip(label: 'Piante da balcone', icon: Icons.deck_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withOpacity(0.75),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: LightTheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: LightTheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: LightTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'In arrivo',
                  style: textTheme.bodyMedium?.copyWith(
                    color: LightTheme.deepForest,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Ricerca intelligente',
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Potrai cercare qualsiasi pianta per nome, specie o caratteristiche. '
            'La funzionalità sarà disponibile nelle prossime versioni di Plantly.',
            style: textTheme.bodyLarge?.copyWith(
              color: LightTheme.deepForest.withOpacity(0.68),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: LightTheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: LightTheme.deepForest,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
