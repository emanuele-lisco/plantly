import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Modello dati per una singola azione rapida.
class QuickAction {
  const QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.highlighted = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool highlighted;
}

/// Riga orizzontale di azioni rapide nella Home — dark botanical.
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key, required this.actions});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          Expanded(child: _QuickActionTile(action: actions[i])),
          if (i < actions.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action});

  final QuickAction action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isHighlighted = action.highlighted;

    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isHighlighted ? LightTheme.accent : LightTheme.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isHighlighted
                ? LightTheme.accent.withOpacity(0.5)
                : LightTheme.midGreen.withOpacity(0.22),
          ),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: LightTheme.accent.withOpacity(0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              action.icon,
              color: isHighlighted ? Colors.white : LightTheme.sage,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              action.label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isHighlighted
                    ? Colors.white
                    : LightTheme.textPrimary,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
