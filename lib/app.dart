import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/core/app_navigator.dart';
import 'package:plantly_app/core/app_router.dart';
import 'package:plantly_app/core/app_state_listener.dart';
import 'package:plantly_app/core/routes.dart';
import 'package:plantly_app/cubits/navigation/auth_flow_cubit.dart';
import 'package:plantly_app/cubits/session/session_cubit.dart';
import 'package:plantly_app/features/theme/models/theme.dart';
import 'package:plantly_app/repositories/user_repository.dart';

class App extends StatelessWidget {
  const App({super.key});

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
        navigatorKey: AppNavigator.navigatorKey,
        initialRoute: Routes.splash,
        onGenerateRoute: AppRouter.generateRoute,
        builder: (context, child) {
          return AppStateListener(
            child: child ?? const SizedBox.shrink(),
          );
        },

      ),
    );
  }
}
