import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/custom/obscure/obscure_cubit.dart';
import '../cubits/forms/sign_up_form_cubit.dart';
import '../cubits/navigation/auth_flow_cubit.dart';
import '../cubits/sign_up/sign_up_cubit.dart';
import '../widgets/auth/google_auth_button.dart';
import '../widgets/sign_up/password_strength.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<SignUpCubit, SignUpState>(
          listener: (context, state) {
            if (state is SignUpFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          child: BlocBuilder<SignUpCubit, SignUpState>(
            builder: (context, signUpState) {
              final loading = signUpState is SignUpLoading;

              return Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: BlocBuilder<SignUpFormCubit, SignUpFormState>(
                      builder: (context, formState) {
                        return Column(
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
                              'Gestisci le tue piante',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
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
                              child: Column(
                                children: [
                                  TextField(
                                    enabled: !loading,
                                    onChanged: context
                                        .read<SignUpFormCubit>()
                                        .updateUsername,
                                    decoration: InputDecoration(
                                      hintText: 'Username',
                                      label: const Text('Username'),
                                      prefixIcon: const Icon(Icons.alternate_email_rounded),
                                      errorText: formState.showErrors
                                          ? formState.usernameError
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          enabled: !loading,
                                          onChanged: context
                                              .read<SignUpFormCubit>()
                                              .updateNome,
                                          decoration: InputDecoration(
                                            hintText: 'Nome',
                                            label: const Text('Nome'),
                                            prefixIcon: const Icon(
                                              Icons.person_outline,
                                            ),
                                            errorText: formState.showErrors
                                                ? formState.nomeError
                                                : null,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          enabled: !loading,
                                          onChanged: context
                                              .read<SignUpFormCubit>()
                                              .updateCognome,
                                          decoration: InputDecoration(
                                            hintText: 'Cognome',
                                            label: const Text('Cognome'),
                                            prefixIcon: const Icon(
                                              Icons.person_outline,
                                            ),
                                            errorText: formState.showErrors
                                                ? formState.cognomeError
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  TextField(
                                    enabled: !loading,
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: context
                                        .read<SignUpFormCubit>()
                                        .updateEmail,
                                    decoration: InputDecoration(
                                      hintText: 'Email',
                                      label: const Text('Email'),
                                      prefixIcon:
                                          const Icon(Icons.email_outlined),
                                      errorText: formState.showErrors
                                          ? formState.emailError
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          enabled: !loading,
                                          onChanged: context
                                              .read<SignUpFormCubit>()
                                              .updateCountry,
                                          decoration: InputDecoration(
                                            hintText: 'Paese',
                                            label: const Text('Paese'),
                                            prefixIcon: const Icon(Icons.public_rounded),
                                            errorText: formState.showErrors
                                                ? formState.countryError
                                                : null,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          enabled: !loading,
                                          onChanged: context
                                              .read<SignUpFormCubit>()
                                              .updateCity,
                                          decoration: InputDecoration(
                                            hintText: 'Città',
                                            label: const Text('Città'),
                                            prefixIcon: const Icon(Icons.location_city_outlined),
                                            errorText: formState.showErrors
                                                ? formState.cityError
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  BlocBuilder<ObscureCubit, ObscureState>(
                                    builder: (context, obscureState) {
                                      return TextField(
                                        enabled: !loading,
                                        obscureText: obscureState.password,
                                        onChanged: context
                                            .read<SignUpFormCubit>()
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
                                  const SizedBox(height: 14),
                                  BlocBuilder<ObscureCubit, ObscureState>(
                                    builder: (context, obscureState) {
                                      return TextField(
                                        enabled: !loading,
                                        obscureText: obscureState.confirmPassword,
                                        onChanged: context
                                            .read<SignUpFormCubit>()
                                            .updateConfirmPassword,
                                        decoration: InputDecoration(
                                          hintText: 'Conferma Password',
                                          label: const Text('Conferma Password'),
                                          prefixIcon:
                                              const Icon(Icons.lock_outline),
                                          suffixIcon: IconButton(
                                            onPressed: () => context
                                                .read<ObscureCubit>()
                                                .toggleConfirmPassword(),
                                            icon: Icon(
                                              obscureState.confirmPassword
                                                  ? Icons.visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              size: 20,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          errorText: formState.showErrors
                                              ? formState.confirmPasswordError
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  PasswordStrength(
                                    strength: formState.passwordStrength,
                                  ),
                                  const SizedBox(height: 22),
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
                                            onPressed: () => context
                                                .read<SignUpFormCubit>()
                                                .submit(),
                                            icon: const Icon(
                                              Icons.spa_rounded,
                                            ),
                                            label: const Text('Crea account'),
                                          ),
                                  ),
                                  const SizedBox(height: 14),
                                  GoogleAuthButton(
                                    label: 'Registrati con Google',
                                    enabled: !loading,
                                    onPressed: loading
                                        ? null
                                        : () => context.read<SignUpCubit>().signUpWithGoogle(),
                                  ),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextButton.icon(
                                      onPressed: loading
                                          ? null
                                          : () => context
                                              .read<AuthFlowCubit>()
                                              .goToSignIn(),
                                      icon: const Icon(
                                        Icons.arrow_back_rounded,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'Hai già un account? Accedi',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
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
