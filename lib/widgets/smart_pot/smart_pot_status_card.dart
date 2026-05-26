import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/smart_pot/smart_pot_cubit.dart';
import '../../features/smart_pot/smart_pot_device.dart';
import '../../features/theme/models/theme.dart';
import 'light_indicator.dart';
import 'smart_pot_no_device_card.dart';
import 'soil_moisture_indicator.dart';
import 'water_tank_estimate_widget.dart';

class SmartPotStatusCard extends StatelessWidget {
  const SmartPotStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SmartPotCubit, SmartPotState>(
      builder: (context, state) {
        return switch (state) {
          SmartPotInitial() || SmartPotLoading() => const _LoadingCard(),
          SmartPotNoDevice() => const SmartPotNoDeviceCard(),
          SmartPotLoaded(device: final d) => _DataCard(device: d, isOnline: true),
          SmartPotOffline(device: final d) => _DataCard(device: d, isOnline: false),
          SmartPotFailure(message: final msg) => _ErrorCard(message: msg),
        };
      },
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: const Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: LightTheme.primary,
          ),
        ),
      ),
    );
  }
}

class _DataCard extends StatelessWidget {
  const _DataCard({required this.device, required this.isOnline});

  final SmartPotDevice device;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final telemetry = device.telemetry;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(
        borderColor: isOnline
            ? LightTheme.primary.withOpacity(0.25)
            : LightTheme.amber.withOpacity(0.30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.sensors_rounded,
                size: 16,
                color: LightTheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Vaso intelligente',
                style: textTheme.labelMedium?.copyWith(
                  color: LightTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _OnlineBadge(isOnline: isOnline),
            ],
          ),
          if (telemetry.pumpActive) ...[
            const SizedBox(height: 10),
            const _PumpActiveBanner(),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, color: LightTheme.border),
          const SizedBox(height: 14),
          SoilMoistureIndicator(percent: telemetry.soilMoisturePercent),
          const SizedBox(height: 12),
          WaterTankEstimateWidget(
            waterRemainingPercent: telemetry.waterRemainingPercent,
            waterRemainingMl:
                telemetry.waterRemainingMl > 0 ? telemetry.waterRemainingMl : null,
          ),
          const SizedBox(height: 12),
          LightIndicator(lux: telemetry.lightLux),
          const SizedBox(height: 12),
          _LastSeen(lastSeenAt: telemetry.lastSeenAt),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(
        borderColor: LightTheme.coral.withOpacity(0.30),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: LightTheme.coral,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodySmall?.copyWith(
                color: LightTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnlineBadge extends StatelessWidget {
  const _OnlineBadge({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = isOnline ? LightTheme.success : LightTheme.amber;
    final label = isOnline ? 'Online' : 'Offline';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _PumpActiveBanner extends StatelessWidget {
  const _PumpActiveBanner();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: LightTheme.water.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: LightTheme.water.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.water_drop_rounded,
            size: 15,
            color: LightTheme.water,
          ),
          const SizedBox(width: 7),
          Text(
            'Irrigazione in corso',
            style: textTheme.bodySmall?.copyWith(
              color: LightTheme.water,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LastSeen extends StatelessWidget {
  const _LastSeen({required this.lastSeenAt});

  final DateTime? lastSeenAt;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final label = lastSeenAt == null
        ? 'Ultima sync: mai ricevuta'
        : 'Ultima sync: ${_formatLastSeen(lastSeenAt!)}';

    return Row(
      children: [
        const Icon(
          Icons.sync_rounded,
          size: 13,
          color: LightTheme.textMuted,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: LightTheme.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  static String _formatLastSeen(DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);

    if (diff.inSeconds < 60) return 'pochi secondi fa';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min fa';
    if (diff.inHours < 24) return '${diff.inHours} ore fa';

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }
}

BoxDecoration _cardDecoration({Color? borderColor}) {
  return BoxDecoration(
    color: LightTheme.surface1,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: borderColor ?? LightTheme.border),
  );
}
