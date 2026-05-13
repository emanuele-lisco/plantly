import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/custom/obscure/obscure_cubit.dart';
import '../../cubits/forms/sign_in_form_cubit.dart';
import '../../cubits/navigation/auth_flow_cubit.dart';
import '../../cubits/sign_in/sign_in_cubit.dart';
import '../../features/theme/models/theme.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/google_auth_button.dart';
import '../../widgets/feedback/snackbar_helper.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightTheme.canvas,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0E0C),
              LightTheme.canvas,
            ],
          ),
        ),
        child: SafeArea(
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
                      vertical: 32,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: Column(
                        children: [
                          // ── Header ──────────────────────────────────────
                          const AuthHeader(
                            subtitle: 'Accedi con email o username',
                          ),

                          const SizedBox(height: 32),

                          // ── Form card ────────────────────────────────────
                          AuthCard(
                            child: BlocBuilder<SignInFormCubit, SignInFormState>(
                              builder: (context, formState) {
                                return Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    // Email / username
                                    TextField(
                                      enabled: !loading,
                                      keyboardType:
                                      TextInputType.emailAddress,
                                      onChanged: context
                                          .read<SignInFormCubit>()
                                          .updateIdentifier,
                                      decoration: InputDecoration(
                                        hintText: 'Email o username',
                                        label:
                                        const Text('Email o username'),
                                        prefixIcon: const Icon(
                                          Icons.alternate_email_rounded,
                                        ),
                                        errorText: formState.showErrors
                                            ? formState.identifierError
                                            : null,
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    // Password
                                    BlocBuilder<ObscureCubit, ObscureState>(
                                      builder: (context, obscureState) {
                                        return TextField(
                                          enabled: !loading,
                                          obscureText:
                                          obscureState.password,
                                          onChanged: context
                                              .read<SignInFormCubit>()
                                              .updatePassword,
                                          decoration: InputDecoration(
                                            hintText: 'Password',
                                            label:
                                            const Text('Password'),
                                            prefixIcon: const Icon(
                                                Icons.lock_outline),
                                            suffixIcon: IconButton(
                                              onPressed: () => context
                                                  .read<ObscureCubit>()
                                                  .togglePassword(),
                                              icon: Icon(
                                                obscureState.password
                                                    ? Icons
                                                    .visibility_off_outlined
                                                    : Icons
                                                    .visibility_outlined,
                                                size: 20,
                                                color:
                                                LightTheme.textSecondary,
                                              ),
                                            ),
                                            errorText: formState.showErrors
                                                ? formState.passwordError
                                                : null,
                                          ),
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 26),

                                    // CTA principale
                                    SizedBox(
                                      width: double.infinity,
                                      child: loading
                                          ? const Center(
                                        child: Padding(
                                          padding:
                                          EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          child:
                                          CircularProgressIndicator(
                                            color: LightTheme.accent,
                                            strokeWidth: 2.5,
                                          ),
                                        ),
                                      )
                                          : ElevatedButton.icon(
                                        onPressed: context
                                            .read<SignInFormCubit>()
                                            .submit,
                                        icon: const Icon(
                                            Icons.login_rounded),
                                        label: const Text('Accedi'),
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    // Separatore
                                    _OrDivider(),

                                    const SizedBox(height: 14),

                                    // Google
                                    GoogleAuthButton(
                                      label: 'Continua con Google',
                                      enabled: !loading,
                                      onPressed: loading
                                          ? null
                                          : () => context
                                          .read<SignInCubit>()
                                          .signInWithGoogle(),
                                    ),

                                    const SizedBox(height: 20),

                                    // Link registrazione
                                    Center(
                                      child: TextButton.icon(
                                        onPressed: loading
                                            ? null
                                            : () => context
                                            .read<AuthFlowCubit>()
                                            .goToSignUp(),
                                        icon: const Icon(
                                          Icons.person_add_alt_1_rounded,
                                          size: 16,
                                        ),
                                        label: const Text(
                                          'Non hai un account? Registrati',
                                          textAlign: TextAlign.center,
                                        ),
                                        style: TextButton.styleFrom(
                                          foregroundColor: LightTheme.sage,
                                          textStyle: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
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
      ),
    );
  }
}

/// Separatore "oppure" tra pulsanti — dark botanical.
class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: LightTheme.midGreen.withOpacity(0.2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'oppure',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: LightTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: LightTheme.midGreen.withOpacity(0.2),
          ),
        ),
      ],
    );
  }
}