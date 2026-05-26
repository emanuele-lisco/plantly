import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/routes.dart';
import '../cubits/forms/google_profile_completion_form_cubit.dart';
import '../cubits/google_profile_completion/google_profile_completion_cubit.dart';
import '../features/theme/models/theme.dart';
import '../widgets/feedback/snackbar_helper.dart';

class GoogleProfileCompletionPage extends StatelessWidget {
  const GoogleProfileCompletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightTheme.warmBackground,
      body: SafeArea(
        child: BlocListener<GoogleProfileCompletionCubit,
            GoogleProfileCompletionState>(
          listener: (context, state) {
            if (state is GoogleProfileCompletionSuccess) {
              SnackBarHelper.showSuccess(
                context,
                'Profilo completato con successo',
              );
              Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.home,
                    (_) => false,
              );
            } else if (state is GoogleProfileCompletionFailure) {
              SnackBarHelper.showError(context, state.message);
            }
          },
          child: BlocBuilder<GoogleProfileCompletionCubit,
              GoogleProfileCompletionState>(
            builder: (context, completionState) {
              final loading =
              completionState is GoogleProfileCompletionLoading;

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
                        // ── Logo ─────────────────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: LightTheme.surface2,
                            border: Border.all(color: LightTheme.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/icon/plantly_logo.png',
                              width: 80,
                              height: 80,
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
                            letterSpacing: -0.5,
                            color: LightTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Completa il tuo profilo per continuare',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            color: LightTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 28),
                        // ── Card form ─────────────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: LightTheme.surface2,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: LightTheme.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: BlocBuilder<
                              GoogleProfileCompletionFormCubit,
                              GoogleProfileCompletionFormState>(
                            builder: (context, formState) {
                              final formCubit = context
                                  .read<GoogleProfileCompletionFormCubit>();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    enabled: !loading,
                                    initialValue: formState.username,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    onChanged: formCubit.updateUsername,
                                    decoration: InputDecoration(
                                      hintText: 'Username',
                                      label: const Text('Username'),
                                      prefixIcon: const Icon(
                                        Icons.alternate_email_rounded,
                                      ),
                                      errorText: formState.showErrors
                                          ? formState.usernameError
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 17),
                                  TextFormField(
                                    enabled: !loading,
                                    initialValue: formState.country,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    onChanged: formCubit.updateCountry,
                                    decoration: InputDecoration(
                                      hintText: 'Paese',
                                      label: const Text('Paese'),
                                      prefixIcon:
                                      const Icon(Icons.flag_outlined),
                                      errorText: formState.showErrors
                                          ? formState.countryError
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 17),
                                  TextFormField(
                                    enabled: !loading,
                                    initialValue: formState.city,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.done,
                                    onChanged: formCubit.updateCity,
                                    onFieldSubmitted: loading
                                        ? null
                                        : (_) => formCubit.submit(),
                                    decoration: InputDecoration(
                                      hintText: 'Città',
                                      label: const Text('Città'),
                                      prefixIcon: const Icon(
                                        Icons.location_city_outlined,
                                      ),
                                      errorText: formState.showErrors
                                          ? formState.cityError
                                          : null,
                                    ),
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
                                        CircularProgressIndicator(
                                          color: LightTheme.primary,
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                    )
                                        : ElevatedButton.icon(
                                      onPressed: formCubit.submit,
                                      icon: const Icon(
                                        Icons
                                            .check_circle_outline_rounded,
                                      ),
                                      label: const Text('Salva e continua'),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
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