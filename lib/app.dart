import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:plantly_app/core/app_router.dart';
import 'package:plantly_app/core/app_state_listener.dart';
import 'package:plantly_app/core/go_router_refresh_stream.dart';
import 'package:plantly_app/cubits/session/session_cubit.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:plantly_app/repositories/user_repository.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final SessionCubit _sessionCubit;
  late final GoRouterRefreshStream _routerRefreshStream;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _sessionCubit = SessionCubit(
      userRepository: context.read<UserRepository>(),
    );

    _routerRefreshStream = GoRouterRefreshStream(_sessionCubit);

    _router = AppRouter.createRouter(
      sessionCubit: _sessionCubit,
      refreshListenable: _routerRefreshStream,
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _routerRefreshStream.dispose();
    _sessionCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _sessionCubit),
      ],
      child: AppStateListener(
        child: MaterialApp.router(
          title: 'Plantly',
          debugShowCheckedModeBanner: false,
          theme: LightTheme.make,
          routerConfig: _router,
        ),
      ),
    );
  }
}