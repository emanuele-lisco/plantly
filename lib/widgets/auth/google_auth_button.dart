import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Pulsante Google per autenticazione — dark botanical.
class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: LightTheme.surface2,
          side: BorderSide(color: LightTheme.midGreen.withOpacity(0.35)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icona G colorata
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LightTheme.surface3,
                border: Border.all(
                  color: LightTheme.midGreen.withOpacity(0.3),
                ),
              ),
              child: Text(
                'G',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: LightTheme.textPrimary,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  color: LightTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}