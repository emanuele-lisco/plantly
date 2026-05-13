import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/blocs/auth/auth_bloc.dart';
import 'package:plantly_app/cubits/profile/profile_cubit.dart';
import 'package:plantly_app/cubits/sign_out/sign_out_cubit.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:plantly_app/features/user/user.dart';

import '../widgets/feedback/snackbar_helper.dart';
import '../widgets/profile/profile_header_widget.dart';
import '../widgets/profile/profile_info_card.dart';
import '../widgets/profile/profile_stats_row.dart';
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
    final authState = context.read<AuthBloc>().state;
    final uid = authState.user?.uid;
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

              return DecoratedBox(
                decoration: const BoxDecoration(
                  //color: LightTheme.canvas,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF071E13),
                      Color(0xFF0A3A20),
                      Color(0xFF071E13),
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                ),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // ── Header con avatar ──────────────────────────────
                    SliverToBoxAdapter(
                      child: ProfileHeaderWidget(
                        initials: initials,
                        displayName: displayName,
                        handle: handle,
                        location: location,
                        bio: profileUser?.bio,
                        imageUrl: imageUrl,
                      ),
                    ),

                    // ── Corpo ──────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stats
                            const ProfileStatsRow(),

                            const SizedBox(height: 28),

                            // Label sezione
                            const _SectionLabel(label: 'Informazioni personali'),
                            const SizedBox(height: 12),

                            // Info card
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
                                if (profileUser != null &&
                                    location.isNotEmpty)
                                  ProfileInfoItem(
                                    icon: Icons.location_on_outlined,
                                    label: 'Posizione',
                                    value: location,
                                  ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            if (profileState is ProfileLoading)
                              const Center(
                                child: CircularProgressIndicator(),
                              ),

                            if (profileState is ProfileFailure) ...[
                              _SectionLabel(label: 'Profilo'),
                              const SizedBox(height: 10),
                              ProfileInfoCard(
                                items: [
                                  ProfileInfoItem(
                                    icon: Icons.warning_amber_rounded,
                                    label: 'Errore',
                                    value: profileState.message,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Azioni rapide profilo
                            _SectionLabel(label: 'Impostazioni'),
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
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _resolveDisplayName(
    PlantlyUser? profileUser,
    String? firebaseDisplayName,
  ) {
    final fromProfile = profileUser?.fullName.trim();
    if (fromProfile != null && fromProfile.isNotEmpty) return fromProfile;
    final fromFirebase = firebaseDisplayName?.trim();
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
      if (parts.length == 1) {
        return parts.first.characters.take(1).toString().toUpperCase();
      }
      return (parts.first.characters.take(1).toString() +
              parts.last.characters.take(1).toString())
          .toUpperCase();
    }
    return (email ?? 'P').characters.take(1).toString().toUpperCase();
  }
}

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
