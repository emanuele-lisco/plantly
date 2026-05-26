import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/blocs/auth/auth_bloc.dart';
import 'package:plantly_app/cubits/garden/garden_cubit.dart';
import 'package:plantly_app/cubits/garden/garden_state.dart';
import 'package:plantly_app/cubits/shell/shell_cubit.dart';
import 'package:plantly_app/features/plant/garden_plant.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:plantly_app/widgets/feedback/snackbar_helper.dart';
import 'package:plantly_app/widgets/garden/garden_empty_state.dart';
import 'package:plantly_app/widgets/garden/garden_header_widget.dart';
import 'package:plantly_app/widgets/garden/garden_stats_banner.dart';
import 'package:plantly_app/widgets/garden/plant_card.dart';

class GardenPage extends StatelessWidget {
  const GardenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: LightTheme.pageGradient),
      child: SafeArea(
        child: BlocBuilder<GardenCubit, GardenState>(
          builder: (context, state) {
            return switch (state) {
              GardenInitial() || GardenLoading() => const _GardenLoadingView(),
              GardenEmpty() => const _GardenContent(plants: []),
              GardenFailure() => _GardenErrorView(message: state.message),
              GardenSuccess() => _GardenContent(plants: state.plants),
            };
          },
        ),
      ),
    );
  }
}

class _GardenContent extends StatelessWidget {
  const _GardenContent({required this.plants});

  final List<GardenPlant> plants;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final wateringDue = plants.where(_isWateringDue).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: [
        GardenHeaderWidget(plantCount: plants.length),
        const SizedBox(height: 20),
        GardenStatsBanner(
          healthAvg: plants.isEmpty ? 0 : 100,
          wateringDue: wateringDue,
          sunExposure: plants.isEmpty ? 0 : 70,
        ),
        const SizedBox(height: 24),
const Divider(),
        const SizedBox(height: 24),
            Text('Le tue piante', style: textTheme.titleLarge),


        const SizedBox(height: 14),
        if (plants.isEmpty) ...[
          const GardenEmptyState(),
          const SizedBox(height: 14),
        ] else ...[
          for (final plant in plants)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: PlantCard(
                plant: plant,
                canWater: _canWaterPlant(plant),
                waterDisabledReason: _waterDisabledReason(plant),
                onWater: _canWaterPlant(plant)
                    ? () => _markAsWatered(context, plant)
                    : null,
                onRemove: () => _confirmRemove(context, plant),
              ),
            ),
        ],
        OutlinedButton.icon(
          onPressed: () => context.read<ShellCubit>().selectTab(2),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Aggiungi una pianta'),
        ),
      ],
    );
  }


  static bool _canWaterPlant(GardenPlant plant) {
    return _hasLinkedSmartPot(plant) && _hasMinimumCareData(plant);
  }

  static bool _hasLinkedSmartPot(GardenPlant plant) {
    return plant.smartPotId != null && plant.smartPotId!.trim().isNotEmpty;
  }

  static bool _hasMinimumCareData(GardenPlant plant) {
    final watering = plant.watering.trim().toLowerCase();
    final hasWatering = watering.isNotEmpty && watering != 'none' && watering != 'non indicata';
    final hasSunlight = plant.sunlight.isNotEmpty;
    final hasNextWatering = plant.nextWateringAt != null;

    return hasWatering && hasSunlight && hasNextWatering;
  }

  static String _waterDisabledReason(GardenPlant plant) {
    if (!_hasLinkedSmartPot(plant)) {
      return 'Collega un vaso intelligente per abilitare l\'irrigazione dall\'app.';
    }

    if (!_hasMinimumCareData(plant)) {
      return 'Completa i dati di cura della pianta prima di abilitare l\'irrigazione.';
    }

    return '';
  }

  static bool _isWateringDue(GardenPlant plant) {
    final next = plant.nextWateringAt;
    if (next == null) return false;
    final now = DateTime.now().toUtc();
    return !next.isAfter(now);
  }

  Future<void> _markAsWatered(BuildContext context, GardenPlant plant) async {
    final userId = context.read<AuthBloc>().state.user?.uid ?? '';
    final result = await context.read<GardenCubit>().markAsWatered(
      userId: userId,
      plant: plant,
    );

    if (!context.mounted) return;
    if (result.isSuccess) {
      SnackBarHelper.showSuccess(context, result.message);
    } else {
      SnackBarHelper.showError(context, result.message);
    }
  }

  Future<void> _confirmRemove(BuildContext context, GardenPlant plant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rimuovere la pianta?'),
        content: Text('Vuoi rimuovere "${plant.displayName}" dal giardino?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Rimuovi'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final userId = context.read<AuthBloc>().state.user?.uid ?? '';
    final result = await context.read<GardenCubit>().removePlant(
      userId: userId,
      plantId: plant.id,
    );

    if (!context.mounted) return;
    if (result.isSuccess) {
      SnackBarHelper.showSuccess(context, result.message);
    } else {
      SnackBarHelper.showError(context, result.message);
    }
  }
}

class _TotalPlantsBadge extends StatelessWidget {
  const _TotalPlantsBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: LightTheme.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count totali',
        style: textTheme.bodyMedium?.copyWith(
          color: LightTheme.accent,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _GardenLoadingView extends StatelessWidget {
  const _GardenLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(LightTheme.accent),
      ),
    );
  }
}

class _GardenErrorView extends StatelessWidget {
  const _GardenErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: [
        const GardenHeaderWidget(),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: LightTheme.danger.withOpacity(0.08),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: LightTheme.danger.withOpacity(0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline_rounded, color: LightTheme.danger),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: textTheme.bodyMedium?.copyWith(color: LightTheme.textSecondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  final userId = context.read<AuthBloc>().state.user?.uid ?? '';
                  context.read<GardenCubit>().watchGarden(userId);
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Riprova'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.read<ShellCubit>().selectTab(2),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Cerca piante'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
