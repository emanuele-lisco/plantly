import 'package:flutter/material.dart';

import '../../features/theme/models/theme.dart';

class InfoUser extends StatelessWidget {
  const InfoUser({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: LightTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: LightTheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          // Label + value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    color: LightTheme.deepForest.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : '—',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Chevron
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: LightTheme.deepForest.withOpacity(0.25),
          ),
        ],
      ),
    );
  }
}
