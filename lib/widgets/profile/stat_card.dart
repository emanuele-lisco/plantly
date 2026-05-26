import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Card statistiche placeholder per il profilo — light botanical.
///
/// Mostra tre colonne: Piante / Giorni / Irrigazioni.
/// I valori sono statici finché non sarà collegato un backend reale.
class StatsCard extends StatelessWidget {
  const StatsCard({
    super.key,
    this.plants = 0,
    this.days = 0,
    this.waterings = 0,
  });

  final int plants;
  final int days;
  final int waterings;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LightTheme.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LightTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _StatItem(
              value: plants > 0 ? '$plants' : '—',
              label: 'Piante',
            ),
            _StatDivider(),
            _StatItem(
              value: days > 0 ? '$days' : '—',
              label: 'Giorni',
            ),
            _StatDivider(),
            _StatItem(
              value: waterings > 0 ? '$waterings' : '—',
              label: 'Irrigazioni',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                color: LightTheme.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: LightTheme.textSecondary,
                fontSize: 11,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      color: LightTheme.border,
    );
  }
}