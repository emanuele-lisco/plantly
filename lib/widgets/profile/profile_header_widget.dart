import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Header profilo utente — light botanical, sfondo chiaro.
class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({
    super.key,
    required this.initials,
    required this.displayName,
    required this.handle,
    required this.location,
    this.bio,
    this.imageUrl,
  });

  final String initials;
  final String displayName;
  final String handle;
  final String location;
  final String? bio;
  final String? imageUrl;

  static double expandedHeight(String? bio) =>
      (bio != null && bio.trim().isNotEmpty) ? 290 : 250;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final subtitle = [
      if (handle.isNotEmpty) handle,
      if (location.isNotEmpty) location,
    ].join(' · ');

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: const Color(0xFFD6DBD0),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(60),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Avatar ────────────────────────────────────────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: LightTheme.sage.withOpacity(0.2),
                    border: Border.all(
                      color: LightTheme.border,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: imageUrl != null && imageUrl!.isNotEmpty
                        ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _InitialsFallback(initials: initials),
                    )
                        : _InitialsFallback(initials: initials),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: LightTheme.surface2,
                      shape: BoxShape.circle,
                      border: Border.all(color: LightTheme.border, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 12,
                      color: LightTheme.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Nome ──────────────────────────────────────────────────────
            Text(
              displayName,
              style: t.titleLarge?.copyWith(
                color: LightTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: t.bodyMedium?.copyWith(
                  color: LightTheme.textSecondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // ── Bio ───────────────────────────────────────────────────────
            if (bio != null && bio!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                bio!,
                style: t.bodyMedium?.copyWith(
                  color: LightTheme.textMuted,
                  height: 1.5,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: LightTheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}