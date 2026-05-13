import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Riga statistiche profilo — dark botanical.
///
/// Dati statici → collegabili a ProfileCubit / GardenCubit.
class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({
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
        color: LightTheme.surface1,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: LightTheme.midGreen.withOpacity(0.22),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _StatItem(
              value: plants > 0 ? '$plants' : '—',
              label: 'Piante',
            ),
            _Divider(),
            _StatItem(
              value: days > 0 ? '$days' : '—',
              label: 'Giorni',
            ),
            _Divider(),
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
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
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
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      color: LightTheme.midGreen.withOpacity(0.18),
    );
  }
}
