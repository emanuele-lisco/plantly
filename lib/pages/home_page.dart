import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:plantly_app/widgets/home/home_greeting_widget.dart';
import 'package:plantly_app/widgets/home/home_hero_card.dart';
import 'package:plantly_app/widgets/home/home_metric_grid.dart';
import 'package:plantly_app/widgets/home/home_quick_actions.dart';
import 'package:plantly_app/widgets/home/home_reminder_card.dart';

/// Home page — botanical dashboard dark-style.
///
/// Struttura leggera: ogni sezione è un widget separato e riutilizzabile.
/// Dati statici → sostituibili con BlocBuilder quando
/// GardenSummaryCubit / TipsCubit saranno implementati.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // ── Dati statici ────────────────────────────────────────────────────────

  static const _metrics = [
    HomeMetric(
      title: 'Piante attive',
      value: '4',
      icon: Icons.local_florist_rounded,
      accent: LightTheme.accent,
    ),
    HomeMetric(
      title: 'Da annaffiare',
      value: '1',
      icon: Icons.opacity_rounded,
      accent: Color(0xFF4FC3F7),
    ),
    HomeMetric(
      title: 'Salute media',
      value: '82%',
      icon: Icons.favorite_rounded,
      accent: LightTheme.accent,
    ),
    HomeMetric(
      title: 'Fioritura',
      value: '2',
      icon: Icons.wb_sunny_rounded,
      accent: LightTheme.amber,
    ),
  ];

  static const _reminders = [
    HomeReminder(
      label: 'Annaffia Monstera',
      icon: Icons.water_drop_rounded,
      urgency: ReminderUrgency.high,
    ),
    HomeReminder(
      label: 'Ruota Ficus verso la luce',
      icon: Icons.wb_sunny_rounded,
      urgency: ReminderUrgency.medium,
    ),
    HomeReminder(
      label: 'Concima Lavanda',
      icon: Icons.eco_rounded,
      urgency: ReminderUrgency.low,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF091A10),
            LightTheme.canvas,
          ],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: [
            // ── Saluto ──────────────────────────────────────────────────
            const HomeGreetingWidget(),

            const SizedBox(height: 22),

            // ── Hero card ───────────────────────────────────────────────
            const HomeHeroCard(),

            const SizedBox(height: 24),

            // ── Azioni rapide ────────────────────────────────────────────
            Row(
              children: [
                Text('Azioni rapide', style: textTheme.titleLarge),
                const Spacer(),
                Text(
                  'Vedi tutto',
                  style: textTheme.bodyMedium?.copyWith(
                    color: LightTheme.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            HomeQuickActions(
              actions: [
                QuickAction(
                  label: 'Giardino',
                  icon: Icons.local_florist_rounded,
                  onTap: () {},
                ),
                QuickAction(
                  label: 'Cerca',
                  icon: Icons.search_rounded,
                  onTap: () {},
                ),
                QuickAction(
                  label: 'Aggiungi',
                  icon: Icons.add_rounded,
                  onTap: () {},
                  highlighted: true,
                ),
                QuickAction(
                  label: 'Annaffia',
                  icon: Icons.water_drop_rounded,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 26),

            // ── Metriche ─────────────────────────────────────────────────
            Row(
              children: [
                Text('Panoramica', style: textTheme.titleLarge),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: LightTheme.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Oggi',
                    style: textTheme.bodyMedium?.copyWith(
                      color: LightTheme.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const HomeMetricGrid(metrics: _metrics),

            const SizedBox(height: 26),

            // ── Promemoria ────────────────────────────────────────────────
            Text('Promemoria', style: textTheme.titleLarge),
            const SizedBox(height: 14),
            for (final r in _reminders) HomeReminderCard(reminder: r),
          ],
        ),
      ),
    );
  }
}
