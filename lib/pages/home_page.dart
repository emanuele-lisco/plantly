import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/blocs/auth/auth_bloc.dart';
import 'package:plantly_app/cubits/garden/garden_cubit.dart';
import 'package:plantly_app/cubits/garden/garden_state.dart';
import 'package:plantly_app/cubits/home/home_cubit.dart';
import 'package:plantly_app/cubits/home/home_state.dart';
import 'package:plantly_app/cubits/profile/profile_cubit.dart';
import 'package:plantly_app/features/plant/garden_plant.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:plantly_app/widgets/home/home_greeting_widget.dart';
import 'package:plantly_app/widgets/home/home_metric_grid.dart';
import 'package:plantly_app/widgets/home/home_reminder_card.dart';
import 'package:plantly_app/widgets/home/home_user_card.dart';
import 'package:go_router/go_router.dart';
import 'package:plantly_app/core/routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<AuthBloc>().state.user;
    final firstName = _firstAvailableName(
      displayName: firebaseUser?.displayName,
      email: firebaseUser?.email,
    );

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: LightTheme.pageGradient),
      child: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                final userId = context.read<AuthBloc>().state.user?.uid;
                if (userId != null && userId.trim().isNotEmpty) {
                  await context.read<HomeCubit>().watchHome(userId);
                }
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                children: [
                  HomeGreetingWidget(
                    greeting:
                    firstName == null ? 'Bentornato' : 'Ciao, $firstName',
                    subtitle: 'La tua dashboard',
                  ),
                  const SizedBox(height: 16),

                  // ── Card utente compatta ─────────────────────────────
                 _UserCardSection(gardenState: state),
                  const SizedBox(height: 22),

                  _buildContent(state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(HomeState state) {
    if (state is HomeInitial || state is HomeLoading) {
      return const _HomeLoadingView();
    }
    if (state is HomeEmpty) {
      return const _HomeEmptyView();
    }
    if (state is HomeFailure) {
      return _HomeFailureView(message: state.message);
    }
    if (state is HomeSuccess) {
      return _HomeDashboardView(state: state);
    }
    return const SizedBox.shrink();
  }

  static String? _firstAvailableName({
    required String? displayName,
    required String? email,
  }) {
    final normalizedName = displayName?.trim();
    if (normalizedName != null && normalizedName.isNotEmpty) {
      return normalizedName.split(RegExp(r'\s+')).first;
    }
    final normalizedEmail = email?.trim();
    if (normalizedEmail != null && normalizedEmail.isNotEmpty) {
      return normalizedEmail.split('@').first;
    }
    return null;
  }
}

// ── Sezione card utente — legge ProfileCubit + GardenCubit ──────────────────

class _UserCardSection extends StatelessWidget {
  const _UserCardSection({required this.gardenState});

  final HomeState gardenState;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        if (profileState is! ProfileLoaded) return const SizedBox.shrink();

        final plantCount = _plantCount(context);

        return HomeUserCard(
          user: profileState.user,
          plantCount: plantCount,
        );
      },
    );
  }

  int _plantCount(BuildContext context) {
    final gardenState = context.watch<GardenCubit>().state;
    if (gardenState is GardenSuccess) return gardenState.plants.length;
    return 0;
  }
}

// ── Dashboard view ───────────────────────────────────────────────────────────

class _HomeDashboardView extends StatelessWidget {
  const _HomeDashboardView({required this.state});

  final HomeSuccess state;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final nextCareLabel = _nextCareLabel(state.nextCarePlant, state.nextCareAt);

    final metrics = [
      HomeMetric(
        title: 'Piante totali',
        value: '${state.totalPlants}',
        icon: Icons.local_florist_rounded,
        accent: LightTheme.primary,
      ),
      HomeMetric(
        title: 'Da annaffiare',
        value: '${state.plantsToWaterTodayCount}',
        icon: Icons.water_drop_rounded,
        accent: LightTheme.water,
      ),
      HomeMetric(
        title: 'Prossima cura',
        value:
        state.nextCareAt == null ? '—' : _shortDate(state.nextCareAt!),
        icon: Icons.event_available_rounded,
        accent: LightTheme.amber,
      ),
      const HomeMetric(
        title: 'Smart pot',
        value: '0',
        icon: Icons.sensors_rounded,
        accent: LightTheme.coral,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Panoramica', trailing: 'Dati reali'),
        const SizedBox(height: 14),
        HomeMetricGrid(metrics: metrics),
        const SizedBox(height: 26),
        Text('Prossima cura', style: t.titleLarge),
        const SizedBox(height: 14),
        HomeReminderCard(
          reminder: HomeReminder(
            label: nextCareLabel,
            icon: Icons.water_drop_rounded,
            urgency: state.plantsToWaterTodayCount > 0
                ? ReminderUrgency.medium
                : ReminderUrgency.low,
          ),
        ),
        const SizedBox(height: 16),
        const _SmartPotPlaceholderCard(),
      ],
    );
  }

  static String _nextCareLabel(GardenPlant? plant, DateTime? date) {
    if (plant == null || date == null) {
      return 'Nessuna cura programmata. Aggiungi più dati alle tue piante.';
    }
    return '${plant.displayName}: prossima cura ${_relativeDateLabel(date)}';
  }

  static String _relativeDateLabel(DateTime date) {
    final now = DateTime.now();
    final localDate = date.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final target =
    DateTime(localDate.year, localDate.month, localDate.day);
    final difference = target.difference(today).inDays;
    if (difference < 0) return 'in ritardo';
    if (difference == 0) return 'oggi';
    if (difference == 1) return 'domani';
    return 'tra $difference giorni';
  }

  static String _shortDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month';
  }
}

// ── Empty view ───────────────────────────────────────────────────────────────

class _HomeEmptyView extends StatelessWidget {
  const _HomeEmptyView();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: LightTheme.surface2,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: LightTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: LightTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.local_florist_rounded,
                  color: LightTheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Il tuo giardino è ancora vuoto',
                style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Cerca una pianta e aggiungila al giardino per iniziare a vedere statistiche, prossime cure e promemoria.',
                style: t.bodyMedium,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () =>
                          context.go(Routes.search),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Aggiungi una pianta'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _SmartPotPlaceholderCard(),
      ],
    );
  }
}

// ── Loading view ─────────────────────────────────────────────────────────────

class _HomeLoadingView extends StatelessWidget {
  const _HomeLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(
        child: CircularProgressIndicator(color: LightTheme.primary),
      ),
    );
  }
}

// ── Failure view ─────────────────────────────────────────────────────────────

class _HomeFailureView extends StatelessWidget {
  const _HomeFailureView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthBloc>().state.user?.uid;
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: LightTheme.surface2,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LightTheme.coral.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: LightTheme.coral),
          const SizedBox(height: 12),
          Text('Dashboard non disponibile', style: t.titleLarge),
          const SizedBox(height: 8),
          Text(message, style: t.bodyMedium),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: userId == null
                ? null
                : () => context.read<HomeCubit>().watchHome(userId),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Riprova'),
          ),
        ],
      ),
    );
  }
}

// ── Smart pot placeholder ─────────────────────────────────────────────────────

class _SmartPotPlaceholderCard extends StatelessWidget {
  const _SmartPotPlaceholderCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LightTheme.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LightTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: LightTheme.water.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.sensors_rounded, color: LightTheme.water),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Smart pot', style: t.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Non collegato. La gestione automatica sarà disponibile nella prossima fase.',
                  style: t.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Row(
      children: [
        Text(title, style: t.titleLarge),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: LightTheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            trailing,
            style: t.bodyMedium?.copyWith(
              color: LightTheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}