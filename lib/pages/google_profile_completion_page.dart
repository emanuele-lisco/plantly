import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/routes.dart';
import '../cubits/forms/google_profile_completion_form_cubit.dart';
import '../cubits/google_profile_completion/google_profile_completion_cubit.dart';

/// Shown when a Google-authenticated user has an incomplete Firestore
/// profile (missing username, country, or city).
///
/// All form state (field values, errors, showErrors flag) is managed by
/// [GoogleProfileCompletionFormCubit], following the same pattern used by
/// [SignInPage] with [SignInFormCubit] and [SignUpPage] with [SignUpFormCubit].
///
/// This page contains no setState(), no TextEditingControllers, and no local
/// validation logic — it is a pure StatelessWidget.
class GoogleProfileCompletionPage extends StatelessWidget {
  const GoogleProfileCompletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Listen to the action cubit for navigation and error snackbars.
        child: BlocListener<GoogleProfileCompletionCubit,
            GoogleProfileCompletionState>(
          listener: (context, state) {
            if (state is GoogleProfileCompletionSuccess) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.home,
                (_) => false,
              );
            } else if (state is GoogleProfileCompletionFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          // Build the UI from the action cubit state (for loading indicator)
          // and the form cubit state (for field values and errors).
          child: BlocBuilder<GoogleProfileCompletionCubit,
              GoogleProfileCompletionState>(
            builder: (context, completionState) {
              final loading = completionState is GoogleProfileCompletionLoading;

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
                        // ── Logo ──────────────────────────────────────────
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
                          'Completa il tuo profilo per continuare',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.black54,
                                  ),
                        ),
                        const SizedBox(height: 28),
                        // ── Form card ─────────────────────────────────────
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
                          child: BlocBuilder<GoogleProfileCompletionFormCubit,
                              GoogleProfileCompletionFormState>(
                            builder: (context, formState) {
                              final formCubit = context
                                  .read<GoogleProfileCompletionFormCubit>();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Username
                                  TextField(
                                    enabled: !loading,
                                    controller: TextEditingController.fromValue(
                                      TextEditingValue(
                                        text: formState.username,
                                        selection: TextSelection.collapsed(
                                          offset: formState.username.length,
                                        ),
                                      ),
                                    ),
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    onChanged: formCubit.updateUsername,
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
                                  const SizedBox(height: 17),
                                  // Country
                                  TextField(
                                    enabled: !loading,
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
                                  // City
                                  TextField(
                                    enabled: !loading,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: loading
                                        ? null
                                        : (_) => formCubit.submit(),
                                    onChanged: formCubit.updateCity,
                                    decoration: InputDecoration(
                                      hintText: 'Città',
                                      label: const Text('Città'),
                                      prefixIcon: const Icon(
                                          Icons.location_city_outlined),
                                      errorText: formState.showErrors
                                          ? formState.cityError
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  // Submit button
                                  SizedBox(
                                    width: double.infinity,
                                    child: loading
                                        ? const Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 12),
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          )
                                        : ElevatedButton.icon(
                                            onPressed: formCubit.submit,
                                            icon: const Icon(Icons
                                                .check_circle_outline_rounded),
                                            label:
                                                const Text('Salva e continua'),
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
