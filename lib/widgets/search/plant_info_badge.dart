import 'package:flutter/material.dart';
import 'package:plantly_app/features/theme/models/theme.dart';

/// Badge informativo riutilizzabile per le proprietà di una pianta.
///
/// Ogni tipo di badge ha un colore semantico preciso:
/// - Watering → blu acqua [LightTheme.water]
/// - Sunlight  → ambra sole [LightTheme.amber]
/// - Indoor    → verde [LightTheme.accent]
/// - Poisonous → rosso soft [LightTheme.danger]
enum PlantBadgeType { watering, sunlight, indoor, outdoor, safe, poisonous }

class PlantInfoBadge extends StatelessWidget {
  const PlantInfoBadge({
    super.key,
    required this.type,
    required this.label,
    this.compact = false,
  });

  final PlantBadgeType type;
  final String label;

  /// Se [compact] è true, mostra solo icona + label breve (per le card griglia).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final config = _config(type);

    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        border: Border.all(
          color: config.color.withOpacity(0.28),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: compact ? 12 : 15, color: config.color),
          const SizedBox(width: 5),
          Text(
            label,
            style: (compact
                ? textTheme.labelSmall
                : textTheme.labelMedium)
                ?.copyWith(
              color: config.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _config(PlantBadgeType t) {
    switch (t) {
      case PlantBadgeType.watering:
        return const _BadgeConfig(LightTheme.water, Icons.water_drop_rounded);
      case PlantBadgeType.sunlight:
        return const _BadgeConfig(LightTheme.amber, Icons.wb_sunny_rounded);
      case PlantBadgeType.indoor:
        return const _BadgeConfig(LightTheme.accent, Icons.home_rounded);
      case PlantBadgeType.outdoor:
        return const _BadgeConfig(LightTheme.sage, Icons.deck_rounded);
      case PlantBadgeType.safe:
        return const _BadgeConfig(LightTheme.accent, Icons.verified_rounded);
      case PlantBadgeType.poisonous:
        return const _BadgeConfig(LightTheme.danger, Icons.warning_amber_rounded);
    }
  }
}

class _BadgeConfig {
  const _BadgeConfig(this.color, this.icon);
  final Color color;
  final IconData icon;
}

// ── Widget dettaglio (riga con icona + titolo + valore) ──────────────────────

/// Riga informativa per la pagina dettaglio: icona colorata + label + valore.
class PlantDetailRow extends StatelessWidget {
  const PlantDetailRow({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: LightTheme.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
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
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: LightTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.bodyLarge?.copyWith(
                    color: LightTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Riga booleana con chip verde/rosso (indoor, poisonous).
class PlantBoolRow extends StatelessWidget {
  const PlantBoolRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.trueLabel,
    required this.falseLabel,
    this.trueIsDangerous = false,
  });

  final IconData icon;
  final String label;
  final bool value;
  final String trueLabel;
  final String falseLabel;

  /// Se true, il valore `true` viene colorato in rosso (es. velenoso).
  final bool trueIsDangerous;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final activeColor = trueIsDangerous
        ? (value ? LightTheme.danger : LightTheme.accent)
        : (value ? LightTheme.accent : LightTheme.textMuted);
    final chipLabel = value ? trueLabel : falseLabel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: LightTheme.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: activeColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: activeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: activeColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyLarge?.copyWith(
                color: LightTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: activeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: activeColor.withOpacity(0.3)),
            ),
            child: Text(
              chipLabel,
              style: textTheme.labelSmall?.copyWith(
                color: activeColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}