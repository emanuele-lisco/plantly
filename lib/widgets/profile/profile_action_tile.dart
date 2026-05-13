import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Tile azione profilo (impostazioni, notifiche, supporto…) — dark botanical.
class ProfileActionTile extends StatelessWidget {
  const ProfileActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: LightTheme.surface1,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: LightTheme.midGreen.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: LightTheme.midGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: LightTheme.sage),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: textTheme.titleMedium?.copyWith(
                  color: LightTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: LightTheme.textMuted,
                ),
          ],
        ),
      ),
    );
  }
}
