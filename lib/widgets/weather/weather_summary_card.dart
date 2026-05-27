import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:plantly_app/features/weather/weather_data.dart';
import 'package:plantly_app/widgets/weather/weather_metric_tile.dart';

import 'condition_wether_animation.dart';

/// Card che mostra il riepilogo meteo del giorno per la città dell'utente.
///
/// Visualizza: condizione, temperatura attuale, min/max, ultimo aggiornamento.
/// Non mostra dati di irrigazione né consigli sull'annaffiatura.
class WeatherSummaryCard extends StatelessWidget {
  const WeatherSummaryCard({super.key, required this.data});

  final WeatherData data;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Hero condition ───────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LightTheme.heroGradient,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      data.locationLabel,
                      style: t.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              WeatherAnimation(condition: data.condition, dt: data.fetchedAt),
              const SizedBox(height: 8),
              Text(
                data.temperatureDisplay,
                style: t.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.condition,
                style: t.bodyLarge?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Metriche ─────────────────────────────────────────────────
        WeatherMetricTile(
          label: 'Min / Max oggi',
          value: data.minMaxDisplay,
          icon: Icons.thermostat_rounded,
          accent: LightTheme.water,
        ),
        const SizedBox(height: 10),
        WeatherMetricTile(
          label: 'Condizione',
          value: '${data.conditionIcon} ${data.condition}',
          icon: Icons.wb_sunny_rounded,
          accent: LightTheme.amber,
        ),
        const SizedBox(height: 10),
        WeatherMetricTile(
          label: 'Ultimo aggiornamento',
          value: _formatFetchedAt(data.fetchedAt),
          icon: Icons.update_rounded,
          accent: LightTheme.sage,
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
    return '$day/$month alle $h:$m';
  }
}
