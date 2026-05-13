import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LightTheme.accent.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: LightTheme.accent.withOpacity(0.15),
        ),
      ),
      child: const IntrinsicHeight(
        child: Row(
          children: [
            _StatItem(value: '—', label: 'Piante'),
            _StatDivider(),
            _StatItem(value: '—', label: 'Giorni'),
            _StatDivider(),
            _StatItem(value: '—', label: 'Irrigazioni'),
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
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: LightTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      color: LightTheme.midGreen.withOpacity(0.18),
    );
  }
}
