import 'package:flutter/material.dart';

import '../../features/theme/models/theme.dart';

class SmartPotNoDeviceCard extends StatelessWidget {
  const SmartPotNoDeviceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: LightTheme.surface3,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LightTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: LightTheme.sage.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sensors_off_rounded,
              color: LightTheme.textMuted,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nessun dispositivo collegato',
                  style: textTheme.labelMedium?.copyWith(
                    color: LightTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Collega un vaso intelligente per monitorare questa pianta.',
                  style: textTheme.bodySmall?.copyWith(
                    color: LightTheme.textMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
