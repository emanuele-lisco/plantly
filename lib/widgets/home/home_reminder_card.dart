import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

enum ReminderUrgency { high, medium, low }

/// Modello per un singolo promemoria cura piante.
class HomeReminder {
  const HomeReminder({
    required this.label,
    required this.icon,
    this.urgency = ReminderUrgency.low,
  });

  final String label;
  final IconData icon;
  final ReminderUrgency urgency;
}

/// Card promemoria per la Home — dark botanical style.
class HomeReminderCard extends StatelessWidget {
  const HomeReminderCard({super.key, required this.reminder});

  final HomeReminder reminder;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final (color, label) = switch (reminder.urgency) {
      ReminderUrgency.high => (LightTheme.danger, 'Urgente'),
      ReminderUrgency.medium => (LightTheme.amber, 'Oggi'),
      ReminderUrgency.low => (LightTheme.sage, 'Questa settimana'),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: LightTheme.surface1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(reminder.icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              reminder.label,
              style: textTheme.titleMedium?.copyWith(
                color: LightTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
