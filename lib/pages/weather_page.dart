import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:plantly_app/core/routes.dart';
import 'package:plantly_app/cubits/profile/profile_cubit.dart';
import 'package:plantly_app/cubits/weather/weather_cubit.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:plantly_app/widgets/weather/weather_location_missing_card.dart';
import 'package:plantly_app/widgets/weather/weather_summary_card.dart';

/// Pagina Meteo.
///
/// - Legge il profilo da [ProfileCubit] (già nell'albero).
/// - Usa [WeatherCubit] per il caricamento dati.
/// - La posizione usata per l'API è sempre quella delle coordinate
///   salvate nel profilo ([PlantlyUser.latitude] / [PlantlyUser.longitude]),
///   che provengono dal geocoding della città selezionata dall'utente.
///   NON usa la posizione GPS del device.
/// - Il pull-to-refresh ricarica solo il meteo, non il profilo.
class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  @override
  void initState() {
    super.initState();
    _triggerLoad();
  }

  void _triggerLoad() {
    final profileState = context.read<ProfileCubit>().state;
    if (profileState is ProfileLoaded) {
      context.read<WeatherCubit>().loadWeather(profileState.user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: LightTheme.pageGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Meteo'),
          centerTitle: false,
        ),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            if (profileState is! ProfileLoaded) {
              return const Center(
                child: CircularProgressIndicator(color: LightTheme.primary),
              );
            }

            final user = profileState.user;

            return BlocBuilder<WeatherCubit, WeatherState>(
              builder: (context, weatherState) {
                return RefreshIndicator(
                  color: LightTheme.primary,
                  onRefresh: () =>
                      context.read<WeatherCubit>().reload(user),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    children: [
                      _buildBody(context, weatherState),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeatherState state) {
    return switch (state) {
      WeatherInitial() || WeatherLoading() => const _LoadingView(),
      WeatherNoLocation() => WeatherLocationMissingCard(
        onGoToProfile: () => context.go(Routes.profile),
      ),
      WeatherLoaded(:final data) => WeatherSummaryCard(data: data),
      WeatherFailure(:final message) => _WeatherErrorView(
        message: message,
        onRetry: () {
          final profileState = context.read<ProfileCubit>().state;
          if (profileState is ProfileLoaded) {
            context.read<WeatherCubit>().reload(profileState.user);
          }
        },
      ),
    };
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: LightTheme.primary),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _WeatherErrorView extends StatelessWidget {
  const _WeatherErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: LightTheme.surface2,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LightTheme.coral.withOpacity(0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: LightTheme.coral.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              color: LightTheme.coral,
              size: 22,
            ),
          ),
          const SizedBox(height: 14),
          Text('Meteo non disponibile', style: t.titleLarge),
          const SizedBox(height: 6),
          Text(message, style: t.bodyMedium),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Riprova'),
            ),
          ),
        ],
      ),
    );
  }
}
