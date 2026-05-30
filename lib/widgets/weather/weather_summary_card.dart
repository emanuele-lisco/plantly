import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:plantly_app/features/weather/weather_data.dart';
import 'package:plantly_app/widgets/weather/weather_metric_tile.dart';

import 'condition_wether_animation.dart';
import 'five_day_forecast_card.dart';

/// Card riepilogo meteo — design production-ready.
///
/// Struttura:
/// 1. Hero card (gradiente verde scuro) con:
///    - città + pin
///    - animazione Lottie condizione (unica rappresentazione visiva)
///    - temperatura attuale grande
///    - riga min/max inline
/// 2. Griglia 2×2 di metriche secondarie:
///    - Umidità, Vento, Pioggia, Aggiornamento
///
/// Nessuna emoji duplicata: la condizione è rappresentata solo
/// dall'animazione Lottie nell'hero. Le tile secondarie usano icone
/// Material, non emoji.
class WeatherSummaryCard extends StatelessWidget {
  const WeatherSummaryCard({super.key, required this.data});

  final WeatherData data;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Hero card ────────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
          decoration: BoxDecoration(
            gradient: LightTheme.heroGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: LightTheme.primaryDark.withOpacity(0.22),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Locality row
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white60,
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      data.locationLabel,
                      style: t.bodySmall?.copyWith(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  WeatherAnimation(
                    condition: data.condition,
                    dt: data.fetchedAt,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.temperatureDisplay,
                          style: t.displayLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 44,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          data.condition,
                          style: t.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Min / Max inline pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.thermostat_rounded,
                      size: 15,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Min / Max  ${data.minMaxDisplay}',
                      style: t.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Griglia metriche 2×2 ────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: WeatherMetricTile(
                label: 'Umidità',
                value: '${data.humidity}%',
                icon: Icons.water_drop_outlined,
                accent: LightTheme.water,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: WeatherMetricTile(
                label: 'Vento',
                value: '${data.windSpeedKmh.toStringAsFixed(1)} km/h',
                icon: Icons.air_rounded,
                accent: LightTheme.sage,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: WeatherMetricTile(
                label: 'Pioggia oggi',
                value: '${data.precipitationProbability}%',
                icon: Icons.umbrella_rounded,
                accent: LightTheme.water,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: WeatherMetricTile(
                label: 'Aggiornato',
                value: _formatFetchedAt(data.fetchedAt),
                icon: Icons.schedule_rounded,
                accent: LightTheme.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        FiveDayForecastCard(
          forecast: data.forecast,
        ),
      ],
    );
  }

  static String _formatFetchedAt(DateTime dt) {
    final local = dt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month · $h:$m';
  }
}
