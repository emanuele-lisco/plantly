import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

class SearchCategory {
  const SearchCategory({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

/// Chip categorie per la pagina Cerca — dark botanical.
class SearchCategoryChips extends StatelessWidget {
  const SearchCategoryChips({super.key, required this.categories});

  final List<SearchCategory> categories;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories.map((c) => _CategoryChip(category: c)).toList(),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final SearchCategory category;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: LightTheme.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: LightTheme.midGreen.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 15, color: LightTheme.sage),
          const SizedBox(width: 7),
          Text(
            category.label,
            style: textTheme.bodyMedium?.copyWith(
              color: LightTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
