import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/cubits/profile/profile_cubit.dart';
import 'package:plantly_app/cubits/weather/weather_cubit.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:plantly_app/widgets/weather/weather_location_missing_card.dart';
import 'package:plantly_app/widgets/weather/weather_summary_card.dart';

/// Pagina meteo semplice.
///
/// - Legge il profilo da [ProfileCubit] (già disponibile nell'albero).
/// - Usa [WeatherCubit] (iniettato nel router) per il caricamento dati.
/// - Non espone né calcola dati di irrigazione.
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
    final t = Theme.of(context).textTheme;

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

            return BlocBuilder<WeatherCubit, WeatherState>(
              builder: (context, weatherState) {
                return RefreshIndicator(
                  color: LightTheme.primary,
                  onRefresh: () =>
                      context.read<WeatherCubit>().reload(profileState.user),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    children: [
                      _buildBody(context, weatherState, t),
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

  Widget _buildBody(
    BuildContext context,
    WeatherState state,
    TextTheme t,
  ) {
    return switch (state) {
      WeatherInitial() || WeatherLoading() => const Padding(
          padding: EdgeInsets.only(top: 80),
          child: Center(
            child: CircularProgressIndicator(color: LightTheme.primary),
          ),
        ),
      WeatherNoLocation() => WeatherLocationMissingCard(
          onGoToProfile: () => Navigator.of(context).pop(),
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

// ── Error view ────────────────────────────────────────────────────────────────

class _WeatherErrorView extends StatelessWidget {
  const _WeatherErrorView({required this.message, required this.onRetry});

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
        border: Border.all(color: LightTheme.coral.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cloud_off_rounded, color: LightTheme.coral, size: 36),
          const SizedBox(height: 14),
          Text('Meteo non disponibile', style: t.titleLarge),
          const SizedBox(height: 8),
          Text(message, style: t.bodyMedium),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Riprova'),
          ),
        ],
      ),
    );
  }
}
