import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/cubits/shell/shell_cubit.dart';
import 'package:plantly_app/pages/garden_page.dart';
import 'package:plantly_app/pages/plant_search_page.dart';
import '../widgets/bottom_appbar/plantly_bottom_navigation.dart';
import 'home_page.dart';
import 'profile_page.dart';

/// Main authenticated shell with bottom navigation.
///
/// Tab state is managed by [ShellCubit] instead of setState(), making it
/// observable, testable, and ready to be driven externally (e.g. deep links).
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  // Tab pages are constant — defined here so they are not recreated on
  // every build() call.
  static const List<Widget> _pages = [
    HomePage(),
    GardenPage(),
    PlantSearchPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShellCubit(),
      child: BlocBuilder<ShellCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            extendBody: true,
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
    );
  }
}
