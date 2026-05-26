import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/blocs/auth/auth_bloc.dart';
import 'package:plantly_app/core/app_navigator.dart';
import 'package:plantly_app/core/app_router.dart';
import 'package:plantly_app/core/routes.dart';
import 'package:plantly_app/cubits/navigation/auth_flow_cubit.dart';
import 'package:plantly_app/cubits/profile/profile_cubit.dart';
import 'package:plantly_app/cubits/session/session_cubit.dart';
import 'package:plantly_app/widgets/feedback/snackbar_helper.dart';

class AppStateListener extends StatelessWidget {
  const AppStateListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthBlocState>(
          listenWhen: (previous, current) {
            if (current.status == AuthStatus.unknown) return false;

            final previousUid = previous.user?.uid;
            final currentUid = current.user?.uid;

            return previous.status != current.status ||
                previousUid != currentUid;
          },
          listener: (context, state) {
            final sessionCubit = context.read<SessionCubit>();
            final profileCubit = context.read<ProfileCubit>();

            if (state.status == AuthStatus.authenticated &&
                state.user != null) {
              sessionCubit.resolveAuthenticatedUser(state.user!);
            } else if (state.status == AuthStatus.unauthenticated) {
              profileCubit.clearProfile();
              sessionCubit.markUnauthenticated();
            }
          },
        ),
        BlocListener<SessionCubit, SessionState>(
          listener: (context, state) {
            if (state is SessionUnauthenticated) {
              AppNavigator.navigateReplace(Routes.signIn);
            } else if (state is SessionAuthenticatedComplete) {
              AppNavigator.navigateReplace(Routes.home);
            } else if (state is SessionAuthenticatedNeedsProfileCompletion) {
              AppNavigator.navigateReplace(
                Routes.googleProfileCompletion,
                arguments: GoogleProfileCompletionRouteArgs(
                  firebaseUser: state.firebaseUser,
                  incompleteUser: state.incompleteUser,
                ),
              );
            } else if (state is SessionFailure) {
              SnackBarHelper.showError(context, state.message);
              AppNavigator.navigateReplace(Routes.signIn);
            }
          },
        ),
        BlocListener<AuthFlowCubit, AuthFlowState>(
          listener: (context, state) {
            if (state.destination == null) return;

            if (state.destination == AuthFlowDestination.signUp) {
              AppNavigator.push(Routes.signUp);
            } else if (state.destination == AuthFlowDestination.signIn) {
              AppNavigator.pushReplacement(Routes.signIn);
            }

            context.read<AuthFlowCubit>().clear();
          },
        ),
      ],
      child: child,
    );
  }
}