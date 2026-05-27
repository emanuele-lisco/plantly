import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/user/user.dart';
import '../../features/weather/weather_data.dart';
import '../../repositories/weather_repository.dart';

part 'weather_state.dart';

/// Cubit responsabile del caricamento dei dati meteo.
///
/// Legge la location da [PlantlyUser.latitude] / [PlantlyUser.longitude].
/// Se la location è assente, emette [WeatherNoLocation].
/// Non calcola né espone dati di irrigazione.
class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit({required WeatherRepository weatherRepository})
      : _weatherRepository = weatherRepository,
        super(const WeatherInitial());

  final WeatherRepository _weatherRepository;

  /// Carica il meteo per la location del profilo utente.
  ///
  /// Emette [WeatherNoLocation] se [user] non ha coordinate valide.
  /// Emette [WeatherLoaded] in caso di successo.
  /// Emette [WeatherFailure] in caso di errore HTTP o parsing.
  Future<void> loadWeather(PlantlyUser user) async {
    final lat = user.latitude;
    final lng = user.longitude;
    final city = user.city.trim();
    final countryName = user.countryName.trim();

    // Location incompleta: città o coordinate mancanti.
    if (lat == null || lng == null || city.isEmpty) {
      emit(const WeatherNoLocation());
      return;
    }

    emit(const WeatherLoading());

    try {
      final data = await _weatherRepository.fetchWeather(
        latitude: lat,
        longitude: lng,
        city: city,
        countryName: countryName,
      );
      emit(WeatherLoaded(data));
    } on WeatherRepositoryException catch (e) {
      emit(WeatherFailure(e.message));
    } catch (_) {
      emit(
        const WeatherFailure(
          'Errore imprevisto durante il caricamento del meteo.',
        ),
      );
    }
  }

  /// Ricarica il meteo — utile per il pull-to-refresh.
  Future<void> reload(PlantlyUser user) => loadWeather(user);
}
