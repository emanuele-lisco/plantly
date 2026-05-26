import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Header auth — logo su sfondo chiaro, verde botanico come accento.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      children: [
        // ── Logo ────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: LightTheme.surface2,
            border: Border.all(color: LightTheme.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/icon/plantly_logo.png',
              width: 76,
              height: 76,
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Wordmark ─────────────────────────────────────────────────────
        Text(
          'Plantly',
          style: t.displaySmall?.copyWith(
            color: LightTheme.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 10),

        // ── Sottotitolo pill ──────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: LightTheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: LightTheme.primary.withOpacity(0.2)),
          ),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: t.bodyMedium?.copyWith(
              color: LightTheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}