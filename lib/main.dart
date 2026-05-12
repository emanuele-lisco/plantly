import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/app.dart';
import 'package:plantly_app/repositories/auth_repository.dart';
import 'package:plantly_app/repositories/user_repository.dart';

import 'blocs/auth/auth_bloc.dart';
import 'cubits/profile/profile_cubit.dart';
import 'cubits/sign_in/sign_in_cubit.dart';
import 'cubits/sign_out/sign_out_cubit.dart';
import 'cubits/sign_up/sign_up_cubit.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  await runZonedGuarded(() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final authRepository = AuthRepository();
      final userRepository = UserRepository();

      runApp(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: authRepository),
            RepositoryProvider.value(value: userRepository),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>(
                create: (_) => AuthBloc(authRepository: authRepository),
              ),
              BlocProvider<SignInCubit>(
                create: (_) => SignInCubit(
                  authRepository: authRepository,
                  userRepository: userRepository,
                ),
              ),
              BlocProvider<SignUpCubit>(
                create: (_) => SignUpCubit(
                  authRepository: authRepository,
                  userRepository: userRepository,
                ),
              ),
              BlocProvider<SignOutCubit>(
                create: (_) => SignOutCubit(authRepository: authRepository),
              ),
              BlocProvider<ProfileCubit>(
                create: (_) => ProfileCubit(userRepository: userRepository),
              ),
            ],
            child: App(),
          ),
        ),
      );
    } catch (e) {
      runApp(_BootstrapErrorApp(error: e.toString()));
    }
  }, (error, stackTrace) {
    debugPrint('Errore non gestito in zona globale: $error');
    debugPrintStack(stackTrace: stackTrace);
  });
}

class _BootstrapErrorApp extends StatelessWidget {
  const _BootstrapErrorApp({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 56,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Errore di inizializzazione',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
