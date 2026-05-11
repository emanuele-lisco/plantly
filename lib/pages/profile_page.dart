import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/blocs/auth/auth_bloc.dart';
import 'package:plantly_app/cubits/profile/profile_cubit.dart';
import 'package:plantly_app/cubits/sign_out/sign_out_cubit.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:plantly_app/features/user/user.dart';

import '../widgets/feedback/snackbar_helper.dart';
import '../widgets/profile/info_card.dart';
import '../widgets/profile/info_user_model.dart';
import '../widgets/profile/logout_button.dart';
import '../widgets/profile/section_label.dart';
import '../widgets/profile/stat_card.dart';

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

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _ProfileHeader(
                      initials: initials,
                      displayName: displayName,
                      handle: handle,
                      location: location,
                      profileUser: profileUser,
                      imageUrl: imageUrl,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionLabel(label: 'Informazioni personali'),
                          const SizedBox(height: 10),
                          InfoCard(
                            children: [
                              InfoUser(
                                icon: Icons.person_outline_rounded,
                                label: 'Nome completo',
                                value: displayName,
                              ),
                              InfoUser(
                                icon: Icons.mail_outline_rounded,
                                label: 'Email',
                                value: email,
                              ),
                              if (profileUser != null && location.isNotEmpty)
                                InfoUser(
                                  icon: Icons.location_on_outlined,
                                  label: 'Posizione',
                                  value: location,
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (profileState is ProfileLoading) ...[
                            const Center(child: CircularProgressIndicator()),
                            const SizedBox(height: 24),
                          ] else if (profileState is ProfileFailure) ...[
                            const SectionLabel(label: 'Profilo'),
                            const SizedBox(height: 10),
                            InfoCard(
                              children: [
                                InfoUser(
                                  icon: Icons.warning_amber_rounded,
                                  label: 'Errore',
                                  value: profileState.message,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                          BlocBuilder<SignOutCubit, SignOutState>(
                            builder: (context, signOutState) {
                              final isSigningOut =
                              signOutState is SignOutLoading;
                              return LogoutButton(
                                loading: isSigningOut,
                                onPressed: isSigningOut
                                    ? null
                                    : () =>
                                    context.read<SignOutCubit>().signOut(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.initials,
    required this.displayName,
    required this.handle,
    required this.location,
    required this.profileUser,
    this.imageUrl,
  });

  final String initials;
  final String displayName;
  final String handle;
  final String location;
  final PlantlyUser? profileUser;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1a5c3a),
            LightTheme.deepForest,
          ],
          stops: [0.0, 0.72],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF2eb872),
                          Color(0xFF0d6e3c),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.18),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: imageUrl != null
                          ? CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          imageUrl ?? 'https://via.placeholder.com/150',
                        ),
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
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2eb872),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: LightTheme.deepForest,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 13,
                        color: LightTheme.deepForest,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                displayName,
                style: textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                [
                  if (handle.isNotEmpty) handle,
                  if (location.isNotEmpty) location,
                ].join(' · '),
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.55),
                ),
                textAlign: TextAlign.center,
              ),
              if (profileUser?.bio != null && profileUser!.bio!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  profileUser!.bio!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.62),
                    height: 1.55,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 22),
              const StatsCard(),
            ],
          ),
        ),
      ),
    );
  }
}