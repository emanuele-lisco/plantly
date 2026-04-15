import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/custom/obscure/obscure_cubit.dart';
import '../cubits/forms/sign_in_form_cubit.dart';
import '../cubits/navigation/auth_flow_cubit.dart';
import '../cubits/sign_in/sign_in_cubit.dart';
import '../widgets/auth/google_auth_button.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<SignInCubit, SignInState>(
          listener: (context, state) {
            if (state is SignInFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  behavior: SnackBarBehavior.floating,
                ),
              );
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
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.asset(
                              'assets/icon/plantly_logo.png',
                              width: 86,
                              height: 86,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Plantly',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Accedi con email o username',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.black54,
                              ),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.04),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
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
                                      prefixIcon: const Icon(Icons.alternate_email_rounded),
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
                                                  ? Icons.visibility_off_outlined
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
                                              child: CircularProgressIndicator(),
                                            ),
                                          )
                                        : ElevatedButton.icon(
                                            onPressed: context
                                                .read<SignInFormCubit>()
                                                .submit,
                                            icon: const Icon(
                                              Icons.login_rounded,
                                            ),
                                            label: const Text('Accedi'),
                                          ),
                                  ),
                                  const SizedBox(height: 14),
                                  GoogleAuthButton(
                                    label: 'Continua con Google',
                                    enabled: !loading,
                                    onPressed: loading
                                        ? null
                                        : () => context.read<SignInCubit>().signInWithGoogle(),
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
