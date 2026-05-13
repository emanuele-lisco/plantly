import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Header profilo utente — dark botanical premium.
///
/// Separato dal ProfilePage per mantenere la pagina leggera.
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
        child: Column(
          children: [
            // ── Avatar ──────────────────────────────────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        LightTheme.accent,
                        LightTheme.midGreen,
                      ],
                    ),
                    border: Border.all(
                      color: LightTheme.accent.withOpacity(0.35),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: LightTheme.accent.withOpacity(0.3),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Center(
                    child: imageUrl != null
                        ? CircleAvatar(
                            radius: 48,
                            backgroundImage: NetworkImage(imageUrl!),
                            backgroundColor: Colors.transparent,
                          )
                        : Text(
                            initials,
                            style: textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                // Badge edit
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: LightTheme.surface2,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: LightTheme.midGreen.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 13,
                      color: LightTheme.accent,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ── Nome ─────────────────────────────────────────────────
            Text(
              displayName,
              style: textTheme.headlineMedium?.copyWith(
                color: LightTheme.textPrimary,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 5),

            // ── Handle + location ──────────────────────────────────
            Text(
              [
                if (handle.isNotEmpty) handle,
                if (location.isNotEmpty) location,
              ].join(' · '),
              style: textTheme.bodyMedium?.copyWith(
                color: LightTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            // ── Bio ───────────────────────────────────────────────
            if (bio != null && bio!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                bio!,
                style: textTheme.bodyMedium?.copyWith(
                  color: LightTheme.textSecondary.withOpacity(0.8),
                  height: 1.55,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
