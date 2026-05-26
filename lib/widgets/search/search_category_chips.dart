import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

class SearchCategory {
  const SearchCategory({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}

class SearchCategoryChips extends StatelessWidget {
  const SearchCategoryChips({
    super.key,
    required this.categories,
    required this.onCategoryTap,
    this.selectedLabel,
  });

  final List<SearchCategory> categories;
  final ValueChanged<SearchCategory> onCategoryTap;
  final String? selectedLabel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories.map((category) {
        final isSelected = selectedLabel?.trim().toLowerCase() ==
            category.label.trim().toLowerCase();

        return _SearchCategoryChip(
          category: category,
          isSelected: isSelected,
          onTap: () => onCategoryTap(category),
        );
      }).toList(),
    );
  }
}

class _SearchCategoryChip extends StatelessWidget {
  const _SearchCategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final SearchCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? LightTheme.accent.withOpacity(0.16)
                : LightTheme.surface2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? LightTheme.accent.withOpacity(0.55)
                  : LightTheme.midGreen.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                category.icon,
                size: 15,
                color: isSelected ? LightTheme.accent : LightTheme.sage,
              ),
              const SizedBox(width: 7),
              Text(
                category.label,
                style: textTheme.bodyMedium?.copyWith(
                  color:
                  isSelected ? LightTheme.accent : LightTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}