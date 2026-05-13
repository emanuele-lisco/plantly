import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:plantly_app/widgets/search/search_bar_widget.dart';
import 'package:plantly_app/widgets/search/search_category_chips.dart';
import 'package:plantly_app/widgets/search/search_coming_soon_card.dart';

/// Pagina Cerca piante — dark botanical.
///
/// Struttura modulare pronta per PlantSearchCubit futuro.
class PlantSearchPage extends StatelessWidget {
  const PlantSearchPage({super.key});

  static const _categories = [
    SearchCategory(label: 'Interno', icon: Icons.home_outlined),
    SearchCategory(label: 'Esterno', icon: Icons.deck_outlined),
    SearchCategory(label: 'Succulente', icon: Icons.wb_sunny_outlined),
    SearchCategory(label: 'Aromatiche', icon: Icons.eco_outlined),
    SearchCategory(label: 'Fioriture', icon: Icons.local_florist_outlined),
    SearchCategory(label: 'Acquatiche', icon: Icons.water_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF091A10),
            LightTheme.canvas,
          ],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: [
            // ── Header ────────────────────────────────────────────────
            Text(
              'Esplora',
              style: textTheme.bodyMedium?.copyWith(
                color: LightTheme.textSecondary,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Cerca una pianta',
              style: textTheme.displaySmall?.copyWith(
                color: LightTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Specie, cura, compatibilità e molto altro.',
              style: textTheme.bodyLarge?.copyWith(
                color: LightTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 22),

            // ── Barra di ricerca ─────────────────────────────────────
            const SearchBarWidget(),

            const SizedBox(height: 24),

            // ── Categorie ────────────────────────────────────────────
            Text('Esplora per categoria', style: textTheme.titleLarge),
            const SizedBox(height: 14),
            const SearchCategoryChips(categories: _categories),

            const SizedBox(height: 26),

            // ── Card "in arrivo" ─────────────────────────────────────
            const SearchComingSoonCard(),
          ],
        ),
      ),
    );
  }
}
