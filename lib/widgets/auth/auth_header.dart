import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Header con logo, titolo e sottotitolo per le schermate auth — dark botanical.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: LightTheme.surface2,
            border: Border.all(
              color: LightTheme.midGreen.withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: LightTheme.accent.withOpacity(0.15),
                blurRadius: 22,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/icon/plantly_logo.png',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Wordmark
        Text(
          'Plantly',
          style: textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: LightTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 8),

        // Sottotitolo pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: LightTheme.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: LightTheme.accent.withOpacity(0.2),
            ),
          ),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: LightTheme.sage,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}