import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

class ProfileInfoItem {
  const ProfileInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

/// Card informazioni profilo — dark botanical.
class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({super.key, required this.items});

  final List<ProfileInfoItem> items;

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
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _InfoRow(item: items[i]),
            if (i < items.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: LightTheme.midGreen.withOpacity(0.15),
                indent: 16,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.item});

  final ProfileInfoItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: LightTheme.midGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, size: 17, color: LightTheme.sage),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: LightTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: textTheme.titleMedium?.copyWith(
                    color: LightTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: LightTheme.textMuted,
          ),
        ],
      ),
    );
  }
}
