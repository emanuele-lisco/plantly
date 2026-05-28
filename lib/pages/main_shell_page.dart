import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:plantly_app/blocs/auth/auth_bloc.dart';
import 'package:plantly_app/cubits/garden/garden_cubit.dart';
import 'package:plantly_app/cubits/home/home_cubit.dart';
import 'package:plantly_app/repositories/garden_repository.dart';
import 'package:plantly_app/repositories/plant_repository.dart';
import 'package:plantly_app/repositories/smart_pot_repository.dart';
import 'package:plantly_app/widgets/bottom_appbar/plantly_bottom_navigation.dart';
import 'package:plantly_app/widgets/navigation/app_drawer.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => PlantRepository()),
        RepositoryProvider(create: (_) => GardenRepository()),
        RepositoryProvider(create: (_) => SmartPotRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => GardenCubit(
              gardenRepository: context.read<GardenRepository>(),
            )..watchGarden(user.uid),
          ),
          BlocProvider(
            create: (context) => HomeCubit(
              gardenRepository: context.read<GardenRepository>(),
            )..watchHome(user.uid),
          ),
        ],
        child: Scaffold(
          extendBody: true,
          drawer: const AppDrawer(),
          body: navigationShell,
          bottomNavigationBar: SafeArea(
            top: false,
            child: PlantlyBottomNav(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}