import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/blocs/auth/auth_bloc.dart';
import 'package:plantly_app/cubits/garden/garden_cubit.dart';
import 'package:plantly_app/cubits/home/home_cubit.dart';
import 'package:plantly_app/cubits/shell/shell_cubit.dart';
import 'package:plantly_app/pages/garden_page.dart';
import 'package:plantly_app/pages/plant_search_page.dart';
import 'package:plantly_app/repositories/garden_repository.dart';
import 'package:plantly_app/repositories/plant_repository.dart';
import 'package:plantly_app/repositories/smart_pot_repository.dart';
import 'package:plantly_app/widgets/navigation/app_drawer.dart';
import '../widgets/bottom_appbar/plantly_bottom_navigation.dart';
import 'home_page.dart';
import 'profile_page.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  static const List<Widget> _pages = [
    HomePage(),
    GardenPage(),
    PlantSearchPage(),
    ProfilePage(),
  ];

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
          BlocProvider(create: (_) => ShellCubit()),
          BlocProvider(
            create: (ctx) => GardenCubit(
              gardenRepository: ctx.read<GardenRepository>(),
            )..watchGarden(user.uid),
          ),
          BlocProvider(
            create: (ctx) => HomeCubit(
              gardenRepository: ctx.read<GardenRepository>(),
            )..watchHome(user.uid),
          ),
        ],
        child: BlocBuilder<ShellCubit, int>(
          builder: (context, currentIndex) {
            return Scaffold(
              extendBody: true,
              // ── Drawer accessibile da tutta la shell ─────────────
              drawer: const AppDrawer(),
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: IndexedStack(
                  key: ValueKey(currentIndex),
                  index: currentIndex,
                  children: _pages,
                ),
              ),
              bottomNavigationBar: SafeArea(
                top: false,
                child: PlantlyBottomNav(
                  currentIndex: currentIndex,
                  onTap: context.read<ShellCubit>().selectTab,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
