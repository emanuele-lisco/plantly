import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/blocs/auth/auth_bloc.dart';
import 'package:plantly_app/cubits/profile/profile_cubit.dart';
import 'package:plantly_app/cubits/sign_out/sign_out_cubit.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:plantly_app/features/user/user.dart';
import 'package:go_router/go_router.dart';
import 'package:plantly_app/core/routes.dart';


/// Drawer principale dell'app.
///
/// Mostra:
/// - avatar/immagine utente se disponibile, altrimenti iniziali
/// - nome completo utente (o email se manca il profilo)
/// - username (@handle) o email
/// - città e paese dal profilo
/// - voce Meteo → naviga a WeatherPage
/// - voce Profilo → porta al tab Profilo nella shell
/// - voce Logout → chiama [SignOutCubit.signOut]
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<AuthBloc>().state.user;
    final profileState = context.watch<ProfileCubit>().state;
    final profileUser =
        profileState is ProfileLoaded ? profileState.user : null;

    final displayName =
        _resolveDisplayName(profileUser, firebaseUser?.displayName);
    final handle = profileUser != null && profileUser.username.trim().isNotEmpty
        ? '@${profileUser.username.trim()}'
        : firebaseUser?.email ?? '';
    final locationLabel = profileUser?.locationLabel ?? '';
    final imageUrl = profileUser?.imageUrl ?? firebaseUser?.photoURL;
    final initials = _initials(displayName, firebaseUser?.email);
    const circular = 18.0;

    return Drawer(
      backgroundColor: LightTheme.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(circular)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header utente ────────────────────────────────────────
            GestureDetector(
              child: _DrawerHeader(
                displayName: displayName,
                handle: handle,
                locationLabel: locationLabel,
                imageUrl: imageUrl,
                initials: initials,
                circular: circular,
              ),
              onTap: () {
                Navigator.of(context).pop();
                context.go(Routes.profile);
              },
            ),

            const Divider(height: 1),
            const SizedBox(height: 8),

            // ── Voci di navigazione ──────────────────────────────────
            _DrawerTile(
              icon: Icons.wb_sunny_outlined,
              label: 'Meteo',
              onTap: () {
                Navigator.of(context).pop();
                context.push(Routes.weather);
              },
            ),
            _DrawerTile(
              icon: Icons.person_outline_rounded,
              label: 'Profilo',
              onTap: () {
                Navigator.of(context).pop();
                context.go(Routes.profile);
              },
            ),

            const Spacer(),
            const Divider(height: 1),

            // ── Logout ───────────────────────────────────────────────
            BlocBuilder<SignOutCubit, SignOutState>(
              builder: (context, state) {
                final loading = state is SignOutLoading;
                return _DrawerTile(
                  icon: Icons.logout_rounded,
                  label: loading ? 'Uscita in corso…' : 'Esci dall\'account',
                  accent: LightTheme.coral,
                  onTap: loading
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          context.read<SignOutCubit>().signOut();
                        },
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static String _resolveDisplayName(PlantlyUser? profile, String? fbName) {
    final full = profile?.fullName.trim();
    if (full != null && full.isNotEmpty) return full;
    final fb = fbName?.trim();
    if (fb != null && fb.isNotEmpty) return fb;
    return 'Utente';
  }

  static String _initials(String name, String? email) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return email?.substring(0, 1).toUpperCase() ?? '?';
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.displayName,
    required this.handle,
    required this.locationLabel,
    required this.imageUrl,
    required this.initials,
    required this.circular,
  });

  final String displayName;
  final String handle;
  final String locationLabel;
  final String? imageUrl;
  final String initials;
  final double circular;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: LightTheme.profileGradient,
        borderRadius: BorderRadius.only(topRight: Radius.circular(circular)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          _Avatar(imageUrl: imageUrl, initials: initials),
          const SizedBox(height: 14),

          // Nome
          Text(
            displayName,
            style: t.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            overflow: TextOverflow.ellipsis,
          ),

          // Handle o email
          if (handle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              handle,
              style: t.bodyMedium?.copyWith(color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Location
          if (locationLabel.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white54,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    locationLabel,
                    style: t.bodySmall?.copyWith(color: Colors.white60),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.imageUrl, required this.initials});

  final String? imageUrl;
  final String initials;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return CircleAvatar(
        radius: 30,
        backgroundColor: Colors.white24,
        backgroundImage: NetworkImage(imageUrl!),
      );
    }

    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.white24,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
    );
  }
}

// ── Tile ──────────────────────────────────────────────────────────────────────

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final color = accent ?? LightTheme.textPrimary;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: t.titleMedium?.copyWith(color: color),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
