import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Modello dati per una singola metrica della Home.
class HomeMetric {
  const HomeMetric({
    required this.title,
    required this.value,
    required this.icon,
    this.accent = LightTheme.accent,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accent;
}

/// Griglia 2×N di card metriche per la Home — dark botanical.
class HomeMetricGrid extends StatelessWidget {
  const HomeMetricGrid({super.key, required this.metrics});

  final List<HomeMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final rows = <List<HomeMetric>>[];
    for (var i = 0; i < metrics.length; i += 2) {
      rows.add(metrics.sublist(i, (i + 2).clamp(0, metrics.length)));
    }

    return Column(
      children: [
        for (final row in rows) ...[
          Row(
            children: [
              for (int i = 0; i < row.length; i++) ...[
                Expanded(child: _MetricCard(metric: row[i])),
                if (i < row.length - 1) const SizedBox(width: 12),
              ],
              if (row.length == 1) const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final HomeMetric metric;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LightTheme.surface1,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: LightTheme.midGreen.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: metric.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(metric.icon, color: metric.accent, size: 18),
          ),
          const SizedBox(height: 14),
          Text(
            metric.title,
            style: textTheme.bodyMedium?.copyWith(
              color: LightTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            metric.value,
            style: textTheme.titleLarge?.copyWith(
              color: LightTheme.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
