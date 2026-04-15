import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/blocs/auth/auth_bloc.dart';
import 'package:plantly_app/cubits/profile/profile_cubit.dart';
import 'package:plantly_app/cubits/sign_out/sign_out_cubit.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignOutCubit, SignOutState>(
      listener: (context, state) {
        if (state is SignOutFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEDE6D8),
              Color(0xFFF7F4EE),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<AuthBloc, AuthBlocState>(
            builder: (context, authState) {
              final authUser = authState.user;
              final isSigningOut =
                  context.watch<SignOutCubit>().state is SignOutLoading;

              if (authUser == null) {
                return const Center(child: CircularProgressIndicator());
              }

              context.read<ProfileCubit>().watchProfile(authUser.uid);

              return BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, profileState) {
                  final profileLoaded = profileState is ProfileLoaded;
                  final profileUser =
                      profileLoaded ? (profileState).user : null;
                  final displayName = profileUser?.fullName.trim().isNotEmpty == true
                      ? profileUser!.fullName
                      : (authUser.displayName?.trim().isNotEmpty == true
                          ? authUser.displayName!
                          : 'Utente Plantly');
                  final initials = _initials(displayName, authUser.email);

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                    children: [
                      Text(
                        'Profilo',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.84),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor:
                                  LightTheme.primary.withOpacity(0.14),
                              child: Text(
                                initials,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: LightTheme.deepForest,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              displayName,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              profileUser?.email ?? authUser.email ?? 'Nessuna email disponibile',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (profileState is ProfileLoading) ...[
                        const _ProfileInfoTile(
                          label: 'Profilo utente',
                          value: 'Caricamento dati in corso...',
                        ),
                      ] else if (profileState is ProfileFailure) ...[
                        _ProfileInfoTile(
                          label: 'Profilo utente',
                          value: profileState.message,
                        ),
                      ] else if (profileUser != null) ...[
                        _ProfileInfoTile(
                          label: 'Username',
                          value: '@${profileUser.username}',
                        ),
                        _ProfileInfoTile(
                          label: 'Località',
                          value: '${profileUser.city}, ${profileUser.country}',
                        ),
                        const _ProfileInfoTile(
                          label: 'Persistenza',
                          value: 'Profilo sincronizzato su Firestore',
                        ),
                      ],
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: isSigningOut
                            ? null
                            : () => context.read<SignOutCubit>().signOut(),
                        icon: isSigningOut
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.logout_rounded),
                        label: Text(isSigningOut ? 'Uscita in corso...' : 'Esci'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _initials(String? displayName, String? email) {
    final cleanedName = displayName?.trim() ?? '';
    if (cleanedName.isNotEmpty) {
      final parts =
          cleanedName.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
      if (parts.length == 1) {
        return parts.first.characters.take(1).toString().toUpperCase();
      }
      return (parts.first.characters.take(1).toString() +
              parts.last.characters.take(1).toString())
          .toUpperCase();
    }
    final fallback = (email ?? 'P').trim();
    return fallback.characters.take(1).toString().toUpperCase();
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
