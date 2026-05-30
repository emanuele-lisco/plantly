import 'package:flutter/material.dart';

import '../../features/weather/weather_data.dart';


class FiveDayForecastCard extends StatelessWidget {
  const FiveDayForecastCard({
    super.key,
    required this.forecast,
  });

  final List<DailyForecast> forecast;

  @override
  Widget build(BuildContext context) {
    final visibleForecast = forecast.take(5).toList();

    if (visibleForecast.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PREVISIONE 5 GIORNI',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              color: colorScheme.onSurface.withOpacity(0.82),
            ),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < visibleForecast.length; i++) ...[
            _ForecastRow(forecast: visibleForecast[i]),
            if (i != visibleForecast.length - 1)
              Divider(
                height: 16,
                thickness: 1,
                color: colorScheme.outline.withOpacity(0.18),
              ),
          ],
        ],
      ),
    );
  }
}

class _ForecastRow extends StatelessWidget {
  const _ForecastRow({
    required this.forecast,
  });

  final DailyForecast forecast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            forecast.dayLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface.withOpacity(0.82),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              forecast.conditionIcon,
              style: const TextStyle(fontSize: 20),
              semanticsLabel: forecast.condition,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            forecast.minDisplay,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface.withOpacity(0.74),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: Text(
            forecast.maxDisplay,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}