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

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

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
}
