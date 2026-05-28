import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:plantly_app/core/go_router_refresh_stream.dart';
import 'package:plantly_app/core/routes.dart';
import 'package:plantly_app/cubits/custom/obscure/obscure_cubit.dart';
import 'package:plantly_app/cubits/forms/google_profile_completion_form_cubit.dart';
import 'package:plantly_app/cubits/forms/sign_in_form_cubit.dart';
import 'package:plantly_app/cubits/forms/sign_up_form_cubit.dart';
import 'package:plantly_app/cubits/garden/garden_cubit.dart';
import 'package:plantly_app/cubits/google_profile_completion/google_profile_completion_cubit.dart';
import 'package:plantly_app/cubits/plant_details/plant_details_cubit.dart';
import 'package:plantly_app/cubits/session/session_cubit.dart';
import 'package:plantly_app/cubits/sign_in/sign_in_cubit.dart';
import 'package:plantly_app/cubits/sign_up/sign_up_cubit.dart';
import 'package:plantly_app/cubits/weather/weather_cubit.dart';
import 'package:plantly_app/features/plant/plant_species.dart';
import 'package:plantly_app/pages/auth/sign_in_page.dart';
import 'package:plantly_app/pages/auth/sign_up_page.dart';
import 'package:plantly_app/pages/garden_page.dart';
import 'package:plantly_app/pages/google_profile_completion_page.dart';
import 'package:plantly_app/pages/home_page.dart';
import 'package:plantly_app/pages/initial/splash_screen.dart';
import 'package:plantly_app/pages/main_shell_page.dart';
import 'package:plantly_app/pages/plant_detail_page.dart';
import 'package:plantly_app/pages/plant_search_page.dart';
import 'package:plantly_app/pages/profile_page.dart';
import 'package:plantly_app/pages/weather_page.dart';
import 'package:plantly_app/repositories/garden_repository.dart';
import 'package:plantly_app/repositories/plant_repository.dart';
import 'package:plantly_app/repositories/user_repository.dart';
import 'package:plantly_app/repositories/weather_repository.dart';

class AppRouter {
  const AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _homeNavigatorKey = GlobalKey<NavigatorState>();
  static final _gardenNavigatorKey = GlobalKey<NavigatorState>();
  static final _searchNavigatorKey = GlobalKey<NavigatorState>();
  static final _profileNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter({
    required SessionCubit sessionCubit,
    required GoRouterRefreshStream refreshListenable,
  }) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: Routes.splash,
      refreshListenable: refreshListenable,
      redirect: (context, state) {
        final sessionState = sessionCubit.state;
        final location = state.matchedLocation;

        final isSplash = location == Routes.splash;
        final isSignIn = location == Routes.signIn;
        final isSignUp = location == Routes.signUp;
        final isAuthRoute = isSignIn || isSignUp;
        final isGoogleProfileCompletion =
            location == Routes.googleProfileCompletion;

        if (sessionState is SessionInitial || sessionState is SessionLoading) {
          return isSplash ? null : Routes.splash;
        }

        if (sessionState is SessionUnauthenticated ||
            sessionState is SessionFailure) {
          return isAuthRoute ? null : Routes.signIn;
        }

        if (sessionState is SessionAuthenticatedNeedsProfileCompletion) {
          return isGoogleProfileCompletion
              ? null
              : Routes.googleProfileCompletion;
        }

        if (sessionState is SessionAuthenticatedComplete) {
          if (isSplash || isAuthRoute || isGoogleProfileCompletion) {
            return Routes.home;
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: Routes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: Routes.signIn,
          builder: (context, state) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => ObscureCubit()),
                BlocProvider(
                  create: (_) => SignInFormCubit(
                    signInCubit: context.read<SignInCubit>(),
                  ),
                ),
              ],
              child: const SignInPage(),
            );
          },
        ),
        GoRoute(
          path: Routes.signUp,
          builder: (context, state) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => ObscureCubit()),
                BlocProvider(
                  create: (_) => SignUpFormCubit(
                    signUpCubit: context.read<SignUpCubit>(),
                  ),
                ),
              ],
              child: const SignUpPage(),
            );
          },
        ),
        GoRoute(
          path: Routes.googleProfileCompletion,
          builder: (context, state) {
            final sessionState = sessionCubit.state;

            if (sessionState is! SessionAuthenticatedNeedsProfileCompletion) {
              return const SplashScreen();
            }

            final completionCubit = GoogleProfileCompletionCubit(
              userRepository: context.read<UserRepository>(),
              firebaseUser: sessionState.firebaseUser,
              incompleteUser: sessionState.incompleteUser,
            );

            return MultiBlocProvider(
              providers: [
                BlocProvider.value(value: completionCubit),
                BlocProvider(
                  create: (_) => GoogleProfileCompletionFormCubit(
                    completionCubit: completionCubit,
                    initialUsername: sessionState.incompleteUser.username,
                  ),
                ),
              ],
              child: const GoogleProfileCompletionPage(),
            );
          },
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainShellPage(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              navigatorKey: _homeNavigatorKey,
              routes: [
                GoRoute(
                  path: Routes.home,
                  builder: (context, state) => const HomePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: _gardenNavigatorKey,
              routes: [
                GoRoute(
                  path: Routes.garden,
                  builder: (context, state) => const GardenPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: _searchNavigatorKey,
              routes: [
                GoRoute(
                  path: Routes.search,
                  builder: (context, state) => const PlantSearchPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: _profileNavigatorKey,
              routes: [
                GoRoute(
                  path: Routes.profile,
                  builder: (context, state) => const ProfilePage(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: Routes.plantDetails,
          builder: (context, state) {
            final args = state.extra;

            if (args is! PlantDetailsRouteArgs) {
              return const _RouteErrorPage(
                message: 'Dati della pianta non disponibili.',
              );
            }

            final plantRepository = PlantRepository();
            final gardenRepository = GardenRepository();

            return MultiRepositoryProvider(
              providers: [
                RepositoryProvider.value(value: plantRepository),
                RepositoryProvider.value(value: gardenRepository),
              ],
              child: MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) => PlantDetailsCubit(
                      plantRepository: plantRepository,
                    )..loadPlantDetails(args.plant),
                  ),
                  BlocProvider(
                    create: (_) => GardenCubit(
                      gardenRepository: gardenRepository,
                    ),
                  ),
                ],
                child: PlantDetailPage(
                  initialPlant: args.plant,
                  userId: args.userId,
                ),
              ),
            );
          },
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: Routes.weather,
          builder: (context, state) {
            return RepositoryProvider(
              create: (_) => WeatherRepository(),
              child: BlocProvider(
                create: (context) => WeatherCubit(
                  weatherRepository: context.read<WeatherRepository>(),
                ),
                child: const WeatherPage(),
              ),
            );
          },
        ),
      ],
      errorBuilder: (context, state) {
        return _RouteErrorPage(
          message: 'Route non trovata: ${state.uri.path}',
        );
      },
    );
  }
}

class PlantDetailsRouteArgs {
  const PlantDetailsRouteArgs({
    required this.plant,
    required this.userId,
  });

  final PlantSpecies plant;
  final String userId;
}

class _RouteErrorPage extends StatelessWidget {
  const _RouteErrorPage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              message,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}