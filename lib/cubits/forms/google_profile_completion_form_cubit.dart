import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/location/city_option.dart';
import '../../features/location/country_option.dart';
import '../google_profile_completion/google_profile_completion_cubit.dart';

class GoogleProfileCompletionFormState extends Equatable {
  final String username;
  final String countryCode;
  final String country;
  final String city;
  final double? latitude;
  final double? longitude;

  final String? usernameError;
  final String? countryError;
  final String? cityError;
  final bool showErrors;

  const GoogleProfileCompletionFormState({
    this.username = '',
    this.countryCode = '',
    this.country = '',
    this.city = '',
    this.latitude,
    this.longitude,
    this.usernameError,
    this.countryError,
    this.cityError,
    this.showErrors = false,
  });

  CountryOption? get selectedCountry => CountryOption.fromValues(
        countryCode: countryCode,
        countryName: country,
      );

  CityOption? get selectedCity {
    if (city.trim().isEmpty) return null;
    return CityOption(
      name: city,
      countryCode: countryCode,
      countryName: country,
      latitude: latitude,
      longitude: longitude,
    );
  }

  GoogleProfileCompletionFormState copyWith({
    String? username,
    String? countryCode,
    String? country,
    String? city,
    double? latitude,
    double? longitude,
    bool clearLatitude = false,
    bool clearLongitude = false,
    Object? usernameError = _keep,
    Object? countryError = _keep,
    Object? cityError = _keep,
    bool? showErrors,
  }) {
    return GoogleProfileCompletionFormState(
      username: username ?? this.username,
      countryCode: countryCode ?? this.countryCode,
      country: country ?? this.country,
      city: city ?? this.city,
      latitude: clearLatitude ? null : latitude ?? this.latitude,
      longitude: clearLongitude ? null : longitude ?? this.longitude,
      usernameError: usernameError == _keep ? this.usernameError : usernameError as String?,
      countryError: countryError == _keep ? this.countryError : countryError as String?,
      cityError: cityError == _keep ? this.cityError : cityError as String?,
      showErrors: showErrors ?? this.showErrors,
    );
  }

  @override
  List<Object?> get props => [
        username,
        countryCode,
        country,
        city,
        latitude,
        longitude,
        usernameError,
        countryError,
        cityError,
        showErrors,
      ];
}

const _keep = Object();

class GoogleProfileCompletionFormCubit
    extends Cubit<GoogleProfileCompletionFormState> {
  GoogleProfileCompletionFormCubit({
    required this.completionCubit,
    String initialUsername = '',
  }) : super(GoogleProfileCompletionFormState(username: initialUsername));

  final GoogleProfileCompletionCubit completionCubit;

  void updateUsername(String value) {
    emit(state.copyWith(
      username: value,
      usernameError: _validateUsername(value),
    ));
  }

  void updateCountry(CountryOption? value) {
    emit(state.copyWith(
      countryCode: value?.code ?? '',
      country: value?.name ?? '',
      city: '',
      clearLatitude: true,
      clearLongitude: true,
      countryError: value == null ? 'Paese obbligatorio' : null,
      cityError: 'Città obbligatoria',
    ));
  }

  void updateCity(CityOption? value) {
    emit(state.copyWith(
      city: value?.name ?? '',
      latitude: value?.latitude,
      longitude: value?.longitude,
      clearLatitude: value == null,
      clearLongitude: value == null,
      cityError: value == null ? 'Seleziona una città dalla lista' : null,
    ));
  }

  Future<void> submit() async {
    final usernameError = _validateUsername(state.username);
    final countryError = _validateRequired(state.countryCode, 'Paese');
    final cityError = _validateRequired(state.city, 'Città');

    final hasError = usernameError != null || countryError != null || cityError != null;

    if (hasError) {
      emit(state.copyWith(
        usernameError: usernameError,
        countryError: countryError,
        cityError: cityError,
        showErrors: true,
      ));
      return;
    }

    await completionCubit.completeProfile(
      username: state.username.trim(),
      countryCode: state.countryCode.trim(),
      country: state.country.trim(),
      city: state.city.trim(),
      latitude: state.latitude,
      longitude: state.longitude,
    );
  }

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
