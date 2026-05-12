import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/custom/obscure/obscure_cubit.dart';
import '../../cubits/forms/sign_in_form_cubit.dart';
import '../../cubits/navigation/auth_flow_cubit.dart';
import '../../cubits/sign_in/sign_in_cubit.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/google_auth_button.dart';
import '../../widgets/feedback/snackbar_helper.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<SignInCubit, SignInState>(
          listener: (context, state) {
            if (state is SignInFailure) {
              SnackBarHelper.showError(context, state.message);
            }
          },
          child: BlocBuilder<SignInCubit, SignInState>(
            builder: (context, signInState) {
              final loading = signInState is SignInLoading;

              return Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      children: [
                        const AuthHeader(
                          subtitle: 'Accedi con email o username',
                        ),
                        const SizedBox(height: 28),
                        AuthCard(
                          child: BlocBuilder<SignInFormCubit, SignInFormState>(
                            builder: (context, formState) {
                              return Column(
                                children: [
                                  TextField(
                                    enabled: !loading,
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: context
                                        .read<SignInFormCubit>()
                                        .updateIdentifier,
                                    decoration: InputDecoration(
                                      hintText: 'Email o username',
                                      label: const Text('Email o username'),
                                      prefixIcon: const Icon(
                                        Icons.alternate_email_rounded,
                                      ),
                                      errorText: formState.showErrors
                                          ? formState.identifierError
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 17),
                                  BlocBuilder<ObscureCubit, ObscureState>(
                                    builder: (context, obscureState) {
                                      return TextField(
                                        enabled: !loading,
                                        obscureText: obscureState.password,
                                        onChanged: context
                                            .read<SignInFormCubit>()
                                            .updatePassword,
                                        decoration: InputDecoration(
                                          hintText: 'Password',
                                          label: const Text('Password'),
                                          prefixIcon:
                                              const Icon(Icons.lock_outline),
                                          suffixIcon: IconButton(
                                            onPressed: () => context
                                                .read<ObscureCubit>()
                                                .togglePassword(),
                                            icon: Icon(
                                              obscureState.password
                                                  ? Icons
                                                      .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              size: 20,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          errorText: formState.showErrors
                                              ? formState.passwordError
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 30),
                                  SizedBox(
                                    width: double.infinity,
                                    child: loading
                                        ? const Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          )
                                        : ElevatedButton.icon(
                                            onPressed: context
                                                .read<SignInFormCubit>()
                                                .submit,
                                            icon:
                                                const Icon(Icons.login_rounded),
                                            label: const Text('Accedi'),
                                          ),
                                  ),
                                  const SizedBox(height: 14),
                                  GoogleAuthButton(
                                    label: 'Continua con Google',
                                    enabled: !loading,
                                    onPressed: loading
                                        ? null
                                        : () => context
                                            .read<SignInCubit>()
                                            .signInWithGoogle(),
                                  ),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextButton.icon(
                                      onPressed: loading
                                          ? null
                                          : () => context
                                              .read<AuthFlowCubit>()
                                              .goToSignUp(),
                                      icon: const Icon(
                                        Icons.person_add_alt_1_rounded,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'Non hai ancora un account? Registrati',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
