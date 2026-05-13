import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/cubits/plant_search/plant_search_cubit.dart';
import 'package:plantly_app/features/plant/plant_species.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:plantly_app/widgets/search/plant_species_card.dart';

/// Griglia risultati ricerca piante.
///
class PlantSpeciesGrid extends StatefulWidget {
  const PlantSpeciesGrid({
    super.key,
    required this.onPlantTap,
  });

  final void Function(PlantSpecies plant) onPlantTap;

  @override
  State<PlantSpeciesGrid> createState() => _PlantSpeciesGridState();
}

class _PlantSpeciesGridState extends State<PlantSpeciesGrid> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PlantSearchCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlantSearchCubit, PlantSearchState>(
      builder: (context, state) {
        return switch (state) {
          PlantSearchInitial() => const SizedBox.shrink(),
          PlantSearchLoading() => _buildLoading(),
          PlantSearchEmpty() => _buildEmpty(state.query),
          PlantSearchFailure() => _buildError(state.message),
          PlantSearchLoaded() => _buildGrid(state),
        };
      },
    );
  }

  // ── Loading ───────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const _SkeletonCard(),
    );
  }

  // ── Empty ─────────────────────────────────────────────────────────────────

  Widget _buildEmpty(String query) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: LightTheme.surface1,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LightTheme.midGreen.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: LightTheme.surface2,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: LightTheme.textMuted,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nessuna pianta trovata',
            style: textTheme.titleMedium?.copyWith(
              color: LightTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Nessun risultato per "$query".\nProva con un nome diverso.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: LightTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────

  Widget _buildError(String message) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LightTheme.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LightTheme.danger.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: LightTheme.danger,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Errore di ricerca',
                  style: textTheme.titleMedium?.copyWith(
                    color: LightTheme.danger,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: textTheme.bodyMedium?.copyWith(
                    color: LightTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Grid ──────────────────────────────────────────────────────────────────

  Widget _buildGrid(PlantSearchLoaded state) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Risultati header
        Row(
          children: [
            Text(
              '${state.plants.length} risultati',
              style: textTheme.bodyMedium?.copyWith(
                color: LightTheme.textSecondary,
              ),
            ),
            const Spacer(),
            if (state.isLoadingMore)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(LightTheme.accent),
                ),
              ),
          ],
        ),

        const SizedBox(height: 14),

        GridView.builder(
          controller: _scrollController,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.72,
          ),
          itemCount: state.plants.length,
          itemBuilder: (_, i) => PlantSpeciesCard(
            plant: state.plants[i],
            onTap: () => widget.onPlantTap(state.plants[i]),
          ),
        ),

        // Load more indicator
        if (state.hasMore && !state.isLoadingMore) ...[
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Scorri per caricare altro',
              style: textTheme.labelSmall?.copyWith(
                color: LightTheme.textMuted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Skeleton Card ─────────────────────────────────────────────────────────────

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final opacity = 0.3 + _anim.value * 0.3;
        return Container(
          decoration: BoxDecoration(
            color: LightTheme.surface1,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: LightTheme.midGreen.withOpacity(0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: LightTheme.surface2.withOpacity(opacity),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 13,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: LightTheme.surface3.withOpacity(opacity),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 10,
                      width: 80,
                      decoration: BoxDecoration(
                        color: LightTheme.surface3.withOpacity(opacity * 0.7),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 22,
                      width: 60,
                      decoration: BoxDecoration(
                        color: LightTheme.surface3.withOpacity(opacity * 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
