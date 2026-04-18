import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../google_profile_completion/google_profile_completion_cubit.dart';

/// Form state for [GoogleProfileCompletionPage].
///
/// Manages the three editable fields (username, country, city), their
/// validation errors, and the showErrors flag — exactly as [SignInFormCubit]
/// and [SignUpFormCubit] do for their respective pages.
///
/// Delegates the actual Firestore save to [GoogleProfileCompletionCubit],
/// which is responsible for persistence and emits the success/failure states.
class GoogleProfileCompletionFormState extends Equatable {
  final String username;
  final String country;
  final String city;

  final String? usernameError;
  final String? countryError;
  final String? cityError;

  /// Whether validation errors should be shown in the UI.
  /// Set to true on the first submit attempt.
  final bool showErrors;

  const GoogleProfileCompletionFormState({
    this.username = '',
    this.country = '',
    this.city = '',
    this.usernameError,
    this.countryError,
    this.cityError,
    this.showErrors = false,
  });

  GoogleProfileCompletionFormState copyWith({
    String? username,
    String? country,
    String? city,
    // Nullable overrides: passing null explicitly clears the error.
    // We use a sentinel pattern here so copyWith can either carry the
    // existing error forward (when the parameter is not passed) or
    // clear it (when null is passed explicitly).
    Object? usernameError = _keep,
    Object? countryError = _keep,
    Object? cityError = _keep,
    bool? showErrors,
  }) {
    return GoogleProfileCompletionFormState(
      username: username ?? this.username,
      country: country ?? this.country,
      city: city ?? this.city,
      usernameError: usernameError == _keep
          ? this.usernameError
          : usernameError as String?,
      countryError:
          countryError == _keep ? this.countryError : countryError as String?,
      cityError: cityError == _keep ? this.cityError : cityError as String?,
      showErrors: showErrors ?? this.showErrors,
    );
  }

  @override
  List<Object?> get props => [
        username,
        country,
        city,
        usernameError,
        countryError,
        cityError,
        showErrors,
      ];
}

// Sentinel object used in copyWith to distinguish "not provided" from null.
const _keep = Object();

/// Handles form validation for [GoogleProfileCompletionPage].
///
/// Follows the same pattern as [SignInFormCubit] and [SignUpFormCubit]:
/// - each field update re-validates that field only
/// - submit() validates all fields and, if valid, delegates to the action cubit
class GoogleProfileCompletionFormCubit
    extends Cubit<GoogleProfileCompletionFormState> {
  GoogleProfileCompletionFormCubit({
    required this.completionCubit,
    String initialUsername = '',
  }) : super(GoogleProfileCompletionFormState(username: initialUsername));

  /// The cubit that owns the Firestore save logic.
  final GoogleProfileCompletionCubit completionCubit;

  // ── Field updates ────────────────────────────────────────────────────────

  void updateUsername(String value) {
    emit(state.copyWith(
      username: value,
      usernameError: _validateUsername(value),
    ));
  }

  void updateCountry(String value) {
    emit(state.copyWith(
      country: value,
      countryError: _validateRequired(value, 'Paese'),
    ));
  }

  void updateCity(String value) {
    emit(state.copyWith(
      city: value,
      cityError: _validateRequired(value, 'Città'),
    ));
  }

  // ── Submit ───────────────────────────────────────────────────────────────

  Future<void> submit() async {
    final usernameError = _validateUsername(state.username);
    final countryError = _validateRequired(state.country, 'Paese');
    final cityError = _validateRequired(state.city, 'Città');

    final hasError =
        usernameError != null || countryError != null || cityError != null;

    if (hasError) {
      emit(state.copyWith(
        usernameError: usernameError,
        countryError: countryError,
        cityError: cityError,
        showErrors: true,
      ));
      return;
    }

    // All fields are valid — delegate to the action cubit.
    await completionCubit.completeProfile(
      username: state.username.trim(),
      country: state.country.trim(),
      city: state.city.trim(),
    );
  }

  // ── Validators ───────────────────────────────────────────────────────────

  String? _validateUsername(String value) {
    final t = value.trim();
    if (t.isEmpty) return 'Username obbligatorio';
    if (t.length < 3) return 'Minimo 3 caratteri';
    if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(t)) {
      return 'Usa solo lettere, numeri, punto o _';
    }
    return null;
  }

  String? _validateRequired(String value, String label) {
    if (value.trim().isEmpty) return '$label obbligatorio';
    return null;
  }
}
