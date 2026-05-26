import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/cubits/custom/obscure/obscure_cubit.dart';
import 'package:plantly_app/cubits/forms/google_profile_completion_form_cubit.dart';
import 'package:plantly_app/cubits/forms/sign_in_form_cubit.dart';
import 'package:plantly_app/cubits/forms/sign_up_form_cubit.dart';
import 'package:plantly_app/cubits/google_profile_completion/google_profile_completion_cubit.dart';
import 'package:plantly_app/cubits/garden/garden_cubit.dart';
import 'package:plantly_app/cubits/plant_details/plant_details_cubit.dart';
import 'package:plantly_app/cubits/sign_in/sign_in_cubit.dart';
import 'package:plantly_app/cubits/sign_up/sign_up_cubit.dart';
import 'package:plantly_app/features/plant/plant_species.dart';
import 'package:plantly_app/features/user/user.dart';
import 'package:plantly_app/pages/google_profile_completion_page.dart';
import 'package:plantly_app/pages/main_shell_page.dart';
import 'package:plantly_app/pages/plant_detail_page.dart' hide GardenCubit;
import 'package:plantly_app/pages/auth/sign_in_page.dart';
import 'package:plantly_app/pages/auth/sign_up_page.dart';
import 'package:plantly_app/pages/initial/splash_screen.dart';
import 'package:plantly_app/repositories/garden_repository.dart';
import 'package:plantly_app/repositories/plant_repository.dart';
import 'package:plantly_app/repositories/user_repository.dart';

import 'routes.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case Routes.signIn:
        return MaterialPageRoute(
          builder: (ctx) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => ObscureCubit()),
              BlocProvider(
                create: (_) => SignInFormCubit(
                  signInCubit: ctx.read<SignInCubit>(),
                ),
              ),
            ],
            child: const SignInPage(),
          ),
        );

      case Routes.signUp:
        return MaterialPageRoute(
          builder: (ctx) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => ObscureCubit()),
              BlocProvider(
                create: (_) => SignUpFormCubit(
                  signUpCubit: ctx.read<SignUpCubit>(),
                ),
              ),
            ],
            child: const SignUpPage(),
          ),
        );

      case Routes.home:
        return MaterialPageRoute(
          builder: (_) => const MainShellPage(),
        );


      case Routes.plantDetails:
        final args = settings.arguments;
        if (args is! PlantDetailsRouteArgs) {
          return _buildFallbackRoute(settings);
        }

        return MaterialPageRoute(
          builder: (ctx) {
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
        );

      case Routes.googleProfileCompletion:
        final args = settings.arguments;
        if (args is! GoogleProfileCompletionRouteArgs) {
          return _buildFallbackRoute(settings);
        }

        return MaterialPageRoute(
          builder: (ctx) {
            final completionCubit = GoogleProfileCompletionCubit(
              userRepository: ctx.read<UserRepository>(),
              firebaseUser: args.firebaseUser,
              incompleteUser: args.incompleteUser,
            );

            return MultiBlocProvider(
              providers: [
                BlocProvider.value(value: completionCubit),
                BlocProvider(
                  create: (_) => GoogleProfileCompletionFormCubit(
                    completionCubit: completionCubit,
                    initialUsername: args.incompleteUser.username,
                  ),
                ),
              ],
              child: const GoogleProfileCompletionPage(),
            );
          },
        );

      default:
        return _buildFallbackRoute(settings);
    }
  }

  static Route<dynamic> _buildFallbackRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(
            'Route non trovata: ${settings.name ?? 'sconosciuta'}',
          ),
        ),
      ),
    );
  }
}

class GoogleProfileCompletionRouteArgs {
  const GoogleProfileCompletionRouteArgs({
    required this.firebaseUser,
    required this.incompleteUser,
  });

  final fb.User firebaseUser;
  final PlantlyUser incompleteUser;
}

class PlantDetailsRouteArgs {
  const PlantDetailsRouteArgs({
    required this.plant,
    required this.userId,
  });

  final PlantSpecies plant;
  final String userId;
}
