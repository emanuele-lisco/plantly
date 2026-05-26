import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/custom/obscure/obscure_cubit.dart';
import '../../cubits/forms/sign_up_form_cubit.dart';
import '../../cubits/navigation/auth_flow_cubit.dart';
import '../../cubits/sign_up/sign_up_cubit.dart';
import '../../features/theme/models/theme.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/google_auth_button.dart';
import '../../widgets/feedback/snackbar_helper.dart';
import '../../widgets/location/city_picker_field.dart';
import '../../widgets/location/country_picker_field.dart';
import '../../widgets/sign_up/password_strength.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightTheme.warmBackground,
      body: SafeArea(
        child: BlocListener<SignUpCubit, SignUpState>(
          listener: (context, state) {
            if (state is SignUpFailure) {
              SnackBarHelper.showError(context, state.message);
            } else if (state is SignUpSuccess) {
              SnackBarHelper.showSuccess(context, state.message);
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
                            const AuthHeader(
                              subtitle: 'Gestisci le tue piante',
                            ),
                            const SizedBox(height: 28),
                            AuthCard(
                              child: Column(
                                children: [
                                  // Username
                                  TextField(
                                    enabled: !loading,
                                    onChanged: context
                                        .read<SignUpFormCubit>()
                                        .updateUsername,
                                    decoration: InputDecoration(
                                      hintText: 'Username',
                                      label: const Text('Username'),
                                      prefixIcon: const Icon(
                                          Icons.alternate_email_rounded),
                                      errorText: formState.showErrors
                                          ? formState.usernameError
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  // Nome + Cognome
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
                                                Icons.person_outline),
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
                                                Icons.person_outline),
                                            errorText: formState.showErrors
                                                ? formState.cognomeError
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  // Email
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
                                  // Paese + Città da API
                                  CountryPickerField(
                                    enabled: !loading,
                                    value: formState.selectedCountry,
                                    onChanged: context
                                        .read<SignUpFormCubit>()
                                        .updateCountry,
                                    errorText: formState.showErrors
                                        ? formState.countryError
                                        : null,
                                  ),
                                  const SizedBox(height: 14),
                                  CityPickerField(
                                    enabled: !loading,
                                    country: formState.selectedCountry,
                                    value: formState.selectedCity,
                                    onSelected: context
                                        .read<SignUpFormCubit>()
                                        .updateCity,
                                    errorText: formState.showErrors
                                        ? formState.cityError
                                        : null,
                                  ),
                                  const SizedBox(height: 14),
                                  // Password
                                  BlocBuilder<ObscureCubit, ObscureState>(
                                    builder: (context, obs) {
                                      return TextField(
                                        enabled: !loading,
                                        obscureText: obs.password,
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
                                              obs.password
                                                  ? Icons
                                                  .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              size: 20,
                                              color: LightTheme.textSecondary,
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
                                  // Conferma password
                                  BlocBuilder<ObscureCubit, ObscureState>(
                                    builder: (context, obs) {
                                      return TextField(
                                        enabled: !loading,
                                        obscureText: obs.confirmPassword,
                                        onChanged: context
                                            .read<SignUpFormCubit>()
                                            .updateConfirmPassword,
                                        decoration: InputDecoration(
                                          hintText: 'Conferma Password',
                                          label:
                                          const Text('Conferma Password'),
                                          prefixIcon:
                                          const Icon(Icons.lock_outline),
                                          suffixIcon: IconButton(
                                            onPressed: () => context
                                                .read<ObscureCubit>()
                                                .toggleConfirmPassword(),
                                            icon: Icon(
                                              obs.confirmPassword
                                                  ? Icons
                                                  .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              size: 20,
                                              color: LightTheme.textSecondary,
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
                                  // CTA
                                  SizedBox(
                                    width: double.infinity,
                                    child: loading
                                        ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12),
                                        child: CircularProgressIndicator(
                                          color: LightTheme.primary,
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                    )
                                        : ElevatedButton.icon(
                                      onPressed: () => context
                                          .read<SignUpFormCubit>()
                                          .submit(),
                                      icon: const Icon(Icons.spa_rounded),
                                      label: const Text('Crea account'),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  GoogleAuthButton(
                                    label: 'Registrati con Google',
                                    enabled: !loading,
                                    onPressed: loading
                                        ? null
                                        : () => context
                                        .read<SignUpCubit>()
                                        .signUpWithGoogle(),
                                  ),
                                  const SizedBox(height: 14),
                                  Center(
                                    child: TextButton.icon(
                                      onPressed: loading
                                          ? null
                                          : () => context
                                          .read<AuthFlowCubit>()
                                          .goToSignIn(),
                                      icon: const Icon(
                                        Icons.arrow_back_rounded,
                                        size: 16,
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