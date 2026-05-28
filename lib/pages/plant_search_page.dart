import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:plantly_app/core/app_router.dart';
import 'package:plantly_app/core/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/blocs/auth/auth_bloc.dart';

import 'package:plantly_app/cubits/plant_search/plant_search_cubit.dart';
import 'package:plantly_app/cubits/plant_search/plant_search_state.dart';
import 'package:plantly_app/features/plant/plant_species.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:plantly_app/repositories/plant_repository.dart';
import 'package:plantly_app/widgets/search/plant_species_card.dart';
import 'package:plantly_app/widgets/search/search_bar_widget.dart';

class PlantSearchPage extends StatelessWidget {
  const PlantSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => PlantSearchCubit(
        plantRepository: ctx.read<PlantRepository>(),
      ),
      child: const _PlantSearchView(),
    );
  }
}

class _PlantSearchView extends StatefulWidget {
  const _PlantSearchView();

  @override
  State<_PlantSearchView> createState() => _PlantSearchViewState();
}

class _PlantSearchViewState extends State<_PlantSearchView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      context.read<PlantSearchCubit>().searchPlants(value);
    });
  }

  void _onSearchSubmitted(String value) {
    _debounce?.cancel();
    context.read<PlantSearchCubit>().searchPlants(value);
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    context.read<PlantSearchCubit>().clearSearch();
  }

  void _openPlantDetail(PlantSpecies plant) {
    final userId = context.read<AuthBloc>().state.user?.uid ?? '';

    context.push(
      Routes.plantDetails,
      extra: PlantDetailsRouteArgs(
        plant: plant,
        userId: userId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: LightTheme.pageGradient),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: [
            Text(
              'Esplora',
              style: textTheme.bodyMedium?.copyWith(
                color: LightTheme.textSecondary,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Cerca una pianta',
              style: textTheme.displaySmall?.copyWith(
                color: LightTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Trova una specie, apri il dettaglio e aggiungila al tuo giardino.',
              style: textTheme.bodyLarge?.copyWith(
                color: LightTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 22),
            SearchBarWidget(
              controller: _searchController,
              hint: 'Cerca una pianta…',
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchSubmitted,
              onClear: _clearSearch,
            ),
            const SizedBox(height: 26),
            BlocBuilder<PlantSearchCubit, PlantSearchState>(
              builder: (context, state) {
                return switch (state) {
                  PlantSearchInitial() => const _InitialSearchState(),
                  PlantSearchLoading() => const _SearchLoadingState(),
                  PlantSearchEmpty() => _SearchEmptyState(query: state.query),
                  PlantSearchFailure() => _SearchErrorState(message: state.message),
                  PlantSearchSuccess() => _SearchResults(
                      plants: state.plants,
                      onPlantTap: _openPlantDetail,
                    ),
                };
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InitialSearchState extends StatelessWidget {
  const _InitialSearchState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: LightTheme.surface1,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LightTheme.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: LightTheme.sage),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Scrivi il nome di una pianta per iniziare la ricerca.',
              style: textTheme.bodyMedium?.copyWith(color: LightTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchLoadingState extends StatelessWidget {
  const _SearchLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 36),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(LightTheme.accent),
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: LightTheme.surface1,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LightTheme.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, color: LightTheme.textMuted, size: 34),
          const SizedBox(height: 12),
          Text('Nessuna pianta trovata', style: textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Nessun risultato per "$query". Prova con un nome diverso.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: LightTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SearchErrorState extends StatelessWidget {
  const _SearchErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
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
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.plants,
    required this.onPlantTap,
  });

  final List<PlantSpecies> plants;
  final void Function(PlantSpecies plant) onPlantTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${plants.length} risultati',
          style: textTheme.bodyMedium?.copyWith(color: LightTheme.textSecondary),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.68,
          ),
          itemCount: plants.length,
          itemBuilder: (_, index) => PlantSpeciesCard(
            plant: plants[index],
            onTap: () => onPlantTap(plants[index]),
          ),
        ),
      ],
    );
  }
}
