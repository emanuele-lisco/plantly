import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Barra di ricerca — dark botanical.
///
/// Quando la ricerca reale sarà implementata, collegare [onChanged]
/// a PlantSearchCubit senza modificare questo widget.
class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    this.hint = 'Nome, specie, o categoria…',
    this.onChanged,
    this.onTap,
  });

  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: LightTheme.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: LightTheme.midGreen.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: LightTheme.sage,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hint,
                style: textTheme.bodyLarge?.copyWith(
                  color: LightTheme.textMuted,
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: LightTheme.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: LightTheme.accent.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 13,
                    color: LightTheme.accent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Filtri',
                    style: textTheme.bodyMedium?.copyWith(
                      color: LightTheme.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
