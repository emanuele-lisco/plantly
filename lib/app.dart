import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/cubits/forms/google_profile_completion_form_cubit.dart';
import 'package:plantly_app/cubits/google_profile_completion/google_profile_completion_cubit.dart';
import 'package:plantly_app/features/user/user.dart';
import 'package:plantly_app/pages/google_profile_completion_page.dart';
import 'package:plantly_app/pages/main_shell_page.dart';
import 'package:plantly_app/pages/sign_pages/sign_in_page.dart';
import 'package:plantly_app/pages/sign_pages/sign_up_page.dart';
import 'package:plantly_app/pages/splash_screen.dart';
import 'package:plantly_app/repositories/user_repository.dart';

import 'blocs/auth/auth_bloc.dart';
import 'core/routes.dart';
import 'cubits/custom/obscure/obscure_cubit.dart';
import 'cubits/forms/sign_in_form_cubit.dart';
import 'cubits/forms/sign_up_form_cubit.dart';
import 'cubits/navigation/auth_flow_cubit.dart';
import 'cubits/sign_in/sign_in_cubit.dart';
import 'cubits/sign_up/sign_up_cubit.dart';
import 'features/theme/models/theme.dart';

class App extends StatelessWidget {
  App({super.key});

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void _navigateReplace(String route, {Object? arguments}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        route,
            (_) => false,
        arguments: arguments,
      );
    });
  }

  void _push(String route) {
    _navigatorKey.currentState?.pushNamed(route);
  }

  void _pushReplacement(String route) {
    _navigatorKey.currentState?.pushReplacementNamed(route);
  }

  bool _isProfileComplete(PlantlyUser? user) {
    if (user == null) return false;

    final username = user.username.trim();
    final country = user.country.trim();
    final city = user.city.trim();

    return username.isNotEmpty && country.isNotEmpty && city.isNotEmpty;
  }

  Future<void> _handleAuthenticatedUser(
      BuildContext context,
      fb.User firebaseUser,
      ) async {
    final userRepository = context.read<UserRepository>();

    try {
      final profile = await userRepository.getUser(firebaseUser.uid);

      if (_isProfileComplete(profile)) {
        _navigateReplace(Routes.home);
        return;
      }

      final incompleteUser =
          profile ??
              PlantlyUser(
                id: firebaseUser.uid,
                username: '',
                name: firebaseUser.displayName?.trim() ?? '',
                surname: '',
                email: firebaseUser.email?.trim() ?? '',
                country: '',
                city: '',
                imageUrl: firebaseUser.photoURL,
                bio: null,
                createdAt: DateTime.now().toUtc(),
                updatedAt: DateTime.now().toUtc(),
              );

      _navigateReplace(
        Routes.googleProfileCompletion,
        arguments: _ProfileCompletionArgs(
          firebaseUser: firebaseUser,
          incompleteUser: incompleteUser,
        ),
      );
    } catch (_) {
      final fallbackUser = PlantlyUser(
        id: firebaseUser.uid,
        username: '',
        name: firebaseUser.displayName?.trim() ?? '',
        surname: '',
        email: firebaseUser.email?.trim() ?? '',
        country: '',
        city: '',
        imageUrl: firebaseUser.photoURL,
        bio: null,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      _navigateReplace(
        Routes.googleProfileCompletion,
        arguments: _ProfileCompletionArgs(
          firebaseUser: firebaseUser,
          incompleteUser: fallbackUser,
        ),
      );
    }
  }

  Route<dynamic> _buildFallbackRoute(RouteSettings settings) {
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthFlowCubit(),
      child: MaterialApp(
        title: 'Plantly',
        debugShowCheckedModeBanner: false,
        theme: LightTheme.make,
        navigatorKey: _navigatorKey,
        initialRoute: Routes.splash,
        onGenerateRoute: (settings) {
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
                      create: (ctx) => SignInFormCubit(
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
                      create: (ctx) => SignUpFormCubit(
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

            case Routes.googleProfileCompletion:
              final args = settings.arguments;
              if (args is! _ProfileCompletionArgs) {
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
        },
        builder: (context, child) {
          return MultiBlocListener(
            listeners: [
              BlocListener<AuthBloc, AuthBlocState>(
                listenWhen: (previous, current) =>
                previous.status != current.status &&
                    current.status != AuthStatus.unknown,
                listener: (context, state) {
                  if (state.status == AuthStatus.authenticated &&
                      state.user != null) {
                    _handleAuthenticatedUser(context, state.user!);
                  } else if (state.status == AuthStatus.unauthenticated) {
                    _navigateReplace(Routes.signIn);
                  }
                },
              ),
              BlocListener<AuthFlowCubit, AuthFlowState>(
                listener: (context, state) {
                  if (state.destination == null) return;

                  if (state.destination == AuthFlowDestination.signUp) {
                    _push(Routes.signUp);
                  } else if (state.destination ==
                      AuthFlowDestination.signIn) {
                    _pushReplacement(Routes.signIn);
                  }

                  context.read<AuthFlowCubit>().clear();
                },
              ),
            ],
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

class _ProfileCompletionArgs {
  const _ProfileCompletionArgs({
    required this.firebaseUser,
    required this.incompleteUser,
  });

  final fb.User firebaseUser;
  final PlantlyUser incompleteUser;
}