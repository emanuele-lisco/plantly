import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:plantly_app/features/user/user.dart';

/// Card utente compatta per la Home — light botanical.
///
/// Mostra avatar, nome, handle e città su righe separate,
/// più due statistiche (piante totali + giorni dall'iscrizione).
/// Si posiziona tra il greeting e la sezione Panoramica.
class HomeUserCard extends StatelessWidget {
  const HomeUserCard({
    super.key,
    required this.user,
    required this.plantCount,
  });

  final PlantlyUser user;
  final int plantCount;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final location = _resolveLocation(user);
    final handle = user.username.isNotEmpty ? '@${user.username}' : '';
    final daysActive = _daysActive(user.createdAt);
    final initials = _initials(user);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: LightTheme.surface2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LightTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Avatar ──────────────────────────────────────────────────
          _Avatar(imageUrl: user.imageUrl, initials: initials),
          const SizedBox(width: 12),

          // ── Nome + handle + location ────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName.isNotEmpty ? user.fullName : 'Utente Plantly',
                  style: t.titleMedium?.copyWith(
                    color: LightTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (handle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    handle,
                    style: t.bodyMedium?.copyWith(
                      color: LightTheme.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 11,
                        color: LightTheme.textMuted,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          location,
                          style: t.bodyMedium?.copyWith(
                            color: LightTheme.textMuted,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Statistiche ─────────────────────────────────────────────
          _StatChip(value: plantCount, label: 'piante'),
          const _VerticalDivider(),
          _StatChip(value: daysActive, label: 'giorni'),
        ],
      ),
    );
  }

  static String _resolveLocation(PlantlyUser user) {
    final city = user.city.trim();
    final country = user.country.trim();
    if (city.isNotEmpty && country.isNotEmpty) return '$city, $country';
    if (city.isNotEmpty) return city;
    if (country.isNotEmpty) return country;
    return '';
  }

  static int _daysActive(DateTime? createdAt) {
    if (createdAt == null) return 0;
    return DateTime.now().difference(createdAt).inDays.clamp(0, 9999);
  }

  static String _initials(PlantlyUser user) {
    final name = user.fullName.trim();
    if (name.isNotEmpty) {
      final parts =
      name.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return parts.first[0].toUpperCase();
    }
    return user.email.isNotEmpty ? user.email[0].toUpperCase() : 'P';
  }
}

// ── Avatar ──────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.imageUrl, required this.initials});

  final String? imageUrl;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: LightTheme.sage.withOpacity(0.25),
        border: Border.all(
          color: LightTheme.primary.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _InitialsFallback(initials: initials, textStyle: t),
        )
            : _InitialsFallback(initials: initials, textStyle: t),
      ),
    );
  }
}

class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback({
    required this.initials,
    required this.textStyle,
  });

  final String initials;
  final TextTheme textStyle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: textStyle.titleMedium?.copyWith(
          color: LightTheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}

// ── Stat chip ───────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: t.titleMedium?.copyWith(
            color: LightTheme.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: t.bodyMedium?.copyWith(
            color: LightTheme.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: LightTheme.border,
    );
  }
}