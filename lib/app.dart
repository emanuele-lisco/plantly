import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/cubits/navigation/auth_flow_cubit.dart';
import 'package:plantly_app/cubits/session/session_cubit.dart';
import 'package:plantly_app/repositories/user_repository.dart';

import 'blocs/auth/auth_bloc.dart';
import 'core/app_router.dart';
import 'core/routes.dart';
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthFlowCubit()),
        BlocProvider(
          create: (ctx) => SessionCubit(
            userRepository: ctx.read<UserRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Plantly',
        debugShowCheckedModeBanner: false,
        theme: LightTheme.make,
        navigatorKey: _navigatorKey,
        initialRoute: Routes.splash,
        onGenerateRoute: (settings) => AppRouter.generateRoute(
          settings,
          context,
        ),
        builder: (context, child) {
          return MultiBlocListener(
            listeners: [
              BlocListener<AuthBloc, AuthBlocState>(
                listenWhen: (previous, current) =>
                previous.status != current.status &&
                    current.status != AuthStatus.unknown,
                listener: (context, state) {
                  final sessionCubit = context.read<SessionCubit>();

                  if (state.status == AuthStatus.authenticated &&
                      state.user != null) {
                    sessionCubit.resolveAuthenticatedUser(state.user!);
                  } else if (state.status == AuthStatus.unauthenticated) {
                    sessionCubit.markUnauthenticated();
                  }
                },
              ),
              BlocListener<SessionCubit, SessionState>(
                listener: (context, state) {
                  if (state is SessionUnauthenticated) {
                    _navigateReplace(Routes.signIn);
                  } else if (state is SessionAuthenticatedComplete) {
                    _navigateReplace(Routes.home);
                  } else if (state
                  is SessionAuthenticatedNeedsProfileCompletion) {
                    _navigateReplace(
                      Routes.googleProfileCompletion,
                      arguments: GoogleProfileCompletionRouteArgs(
                        firebaseUser: state.firebaseUser,
                        incompleteUser: state.incompleteUser,
                      ),
                    );
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