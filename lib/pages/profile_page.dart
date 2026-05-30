import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/blocs/auth/auth_bloc.dart';
import 'package:plantly_app/cubits/profile/profile_cubit.dart';
import 'package:plantly_app/cubits/sign_out/sign_out_cubit.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:plantly_app/features/user/user.dart';

import '../widgets/feedback/snackbar_helper.dart';
import '../widgets/profile/profile_header_widget.dart';
import '../widgets/profile/profile_info_card.dart';
import '../widgets/profile/profile_action_tile.dart';
import '../widgets/profile/logout_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthBloc>().state.user?.uid;
    if (uid != null && uid.isNotEmpty) {
      context.read<ProfileCubit>().watchProfile(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignOutCubit, SignOutState>(
      listener: (context, state) {
        if (state is SignOutFailure) {
          SnackBarHelper.showError(context, state.message);
        }
      },
      child: BlocBuilder<AuthBloc, AuthBlocState>(
        builder: (context, authState) {
          final authUser = authState.user;
          if (authUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              final profileUser =
              profileState is ProfileLoaded ? profileState.user : null;

              final displayName =
              _resolveDisplayName(profileUser, authUser.displayName);
              final initials = _initials(displayName, authUser.email);
              final email = profileUser?.email ?? authUser.email ?? '';
              final handle =
              profileUser != null ? '@${profileUser.username}' : '';
              final location = _resolveLocation(profileUser);
              final imageUrl = profileUser?.imageUrl;
              final bio = profileUser?.bio;

              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle.dark,
                child: Scaffold(
                  backgroundColor: LightTheme.canvas,
                  body: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // ── SliverAppBar con header verde ─────────────────
                      SliverAppBar(
                        expandedHeight:
                        ProfileHeaderWidget.expandedHeight(bio),
                        pinned: false,
                        stretch: true,
                        backgroundColor: LightTheme.canvas,
                        systemOverlayStyle: SystemUiOverlayStyle.dark,
                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.pin,
                          background: SafeArea(
                            top: false,
                            child: ProfileHeaderWidget(
                              initials: initials,
                              displayName: displayName,
                              handle: handle,
                              location: location,
                              bio: bio,
                              imageUrl: imageUrl,
                            ),
                          ),
                        ),
                      ),

                      // ── Corpo scrollabile ─────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _SectionLabel(
                                  label: 'Informazioni personali'),
                              const SizedBox(height: 12),
                              ProfileInfoCard(
                                items: [
                                  ProfileInfoItem(
                                    icon: Icons.person_outline_rounded,
                                    label: 'Nome completo',
                                    value: displayName,
                                  ),
                                  ProfileInfoItem(
                                    icon: Icons.mail_outline_rounded,
                                    label: 'Email',
                                    value: email,
                                  ),
                                  if (location.isNotEmpty)
                                    ProfileInfoItem(
                                      icon: Icons.location_on_outlined,
                                      label: 'Posizione',
                                      value: location,
                                    ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Stato loading / errore profilo
                              if (profileState is ProfileLoading)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: LightTheme.primary,
                                    ),
                                  ),
                                ),

                              if (profileState is ProfileFailure) ...[
                                const SizedBox(height: 16),
                                _ErrorBanner(message: profileState.message),
                              ],

                              const SizedBox(height: 24),

                              // Impostazioni
                              const _SectionLabel(label: 'Impostazioni'),
                              const SizedBox(height: 12),
                              ProfileActionTile(
                                icon: Icons.settings_outlined,
                                label: 'Impostazioni app',
                                onTap: () {},
                              ),
                              ProfileActionTile(
                                icon: Icons.notifications_outlined,
                                label: 'Notifiche',
                                onTap: () {},
                              ),
                              ProfileActionTile(
                                icon: Icons.help_outline_rounded,
                                label: 'Supporto',
                                onTap: () {},
                              ),

                              const SizedBox(height: 28),

                              // Logout
                              BlocBuilder<SignOutCubit, SignOutState>(
                                builder: (context, signOutState) {
                                  final isSigningOut =
                                  signOutState is SignOutLoading;
                                  return LogoutButton(
                                    loading: isSigningOut,
                                    onPressed: isSigningOut
                                        ? null
                                        : () => context
                                        .read<SignOutCubit>()
                                        .signOut(),
                                  );
                                },
                              ),

                              // Spazio per la bottom nav
                              const SizedBox(height: 110),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _resolveDisplayName(PlantlyUser? user, String? firebaseName) {
    final fromProfile = user?.fullName.trim();
    if (fromProfile != null && fromProfile.isNotEmpty) return fromProfile;
    final fromFirebase = firebaseName?.trim();
    if (fromFirebase != null && fromFirebase.isNotEmpty) return fromFirebase;
    return 'Utente Plantly';
  }

  String _resolveLocation(PlantlyUser? user) {
    if (user == null) return '';
    final city = user.city.trim();
    final country = user.country.trim();
    if (city.isNotEmpty && country.isNotEmpty) return '$city, $country';
    if (city.isNotEmpty) return city;
    if (country.isNotEmpty) return country;
    return '';
  }

  String _initials(String displayName, String? email) {
    final name = displayName.trim();
    if (name.isNotEmpty) {
      final parts =
      name.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
      if (parts.length == 1) return parts.first[0].toUpperCase();
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return (email ?? 'P')[0].toUpperCase();
  }
}

// ── Widgets locali ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: LightTheme.textSecondary,
        fontWeight: FontWeight.w700,
        fontSize: 11,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LightTheme.danger.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LightTheme.danger.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: LightTheme.danger, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: LightTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}