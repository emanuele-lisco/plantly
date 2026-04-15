import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/pages/main_shell_page.dart';
import 'package:plantly_app/pages/sign_in_page.dart';
import 'package:plantly_app/pages/sign_up_page.dart';
import 'package:plantly_app/pages/splash_screen.dart';

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

  // Naviga solo quando il Navigator è effettivamente pronto.
  // Questo risolve il caso in cui AuthBloc emette uno stato prima che
  // il Navigator sia montato (es. primo frame su cold start).
  void _navigate(String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        route,
        (_) => false,
      );
    });
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

            default:
              return null;
          }
        },

        builder: (context, child) {
          return MultiBlocListener(
            listeners: [
              BlocListener<AuthBloc, AuthBlocState>(
                // listenWhen evita di reagire allo stato `unknown` iniziale
                // e a re-emit dello stesso status (es. refresh token Firebase).
                listenWhen: (previous, current) =>
                    previous.status != current.status &&
                    current.status != AuthStatus.unknown,
                listener: (context, state) {
                  if (state.status == AuthStatus.authenticated) {
                    _navigate(Routes.home);
                  } else if (state.status == AuthStatus.unauthenticated) {
                    _navigate(Routes.signIn);
                  }
                },
              ),
              BlocListener<AuthFlowCubit, AuthFlowState>(
                listener: (context, state) {
                  if (state.destination == null) return;

                  if (state.destination == AuthFlowDestination.signUp) {
                    _navigatorKey.currentState?.pushNamed(Routes.signUp);
                  } else if (state.destination == AuthFlowDestination.signIn) {
                    _navigatorKey.currentState
                        ?.pushReplacementNamed(Routes.signIn);
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
