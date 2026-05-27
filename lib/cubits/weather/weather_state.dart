part of 'weather_cubit.dart';

sealed class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

/// Stato iniziale — nessuna operazione avviata.
final class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

/// Caricamento in corso.
final class WeatherLoading extends WeatherState {
  const WeatherLoading();
}

/// Location mancante nel profilo utente.
/// Mostra messaggio "Completa il profilo per visualizzare il meteo locale".
final class WeatherNoLocation extends WeatherState {
  const WeatherNoLocation();
}

/// Dati meteo caricati con successo.
final class WeatherLoaded extends WeatherState {
  const WeatherLoaded(this.data);

  final WeatherData data;

  @override
  List<Object?> get props => [data];
}

/// Errore durante il caricamento.
final class WeatherFailure extends WeatherState {
  const WeatherFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
