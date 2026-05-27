import 'package:equatable/equatable.dart';

/// Dati meteo giornalieri restituiti da Open-Meteo.
///
/// Questo model è usato esclusivamente per la visualizzazione nella
/// [WeatherPage]. Non è collegato a nessuna logica di irrigazione.
class WeatherData extends Equatable {
  const WeatherData({
    required this.city,
    required this.countryName,
    required this.temperatureCelsius,
    required this.minTemperatureCelsius,
    required this.maxTemperatureCelsius,
    required this.condition,
    required this.conditionIcon,
    required this.fetchedAt,
  });

  /// Città del profilo utente — usata solo come label display.
  final String city;

  /// Paese del profilo utente — usato solo come label display.
  final String countryName;

  /// Temperatura attuale in °C.
  final double temperatureCelsius;

  /// Minima giornaliera in °C.
  final double minTemperatureCelsius;

  /// Massima giornaliera in °C.
  final double maxTemperatureCelsius;

  /// Descrizione testuale della condizione meteo (es. "Parzialmente nuvoloso").
  final String condition;

  /// Emoji/icona associata alla condizione (es. "⛅").
  final String conditionIcon;

  /// Timestamp di quando il dato è stato recuperato dall'API.
  final DateTime fetchedAt;

  String get locationLabel {
    final parts = [
      if (city.trim().isNotEmpty) city.trim(),
      if (countryName.trim().isNotEmpty) countryName.trim(),
    ];
    return parts.join(', ');
  }

  String get temperatureDisplay =>
      '${temperatureCelsius.toStringAsFixed(1)}°C';

  String get minMaxDisplay =>
      '${minTemperatureCelsius.toStringAsFixed(1)}° / ${maxTemperatureCelsius.toStringAsFixed(1)}°';

  @override
  List<Object?> get props => [
        city,
        countryName,
        temperatureCelsius,
        minTemperatureCelsius,
        maxTemperatureCelsius,
        condition,
        conditionIcon,
        fetchedAt,
      ];
}

/// Mappa i WMO Weather Interpretation Codes restituiti da Open-Meteo
/// in descrizione testuale italiana + emoji.
///
/// Ref: https://open-meteo.com/en/docs#weathervariables
({String label, String icon}) weatherConditionFromCode(int code) {
  return switch (code) {
    0 => (label: 'Sereno', icon: '☀️'),
    1 => (label: 'Principalmente sereno', icon: '🌤️'),
    2 => (label: 'Parzialmente nuvoloso', icon: '⛅'),
    3 => (label: 'Coperto', icon: '☁️'),
    45 || 48 => (label: 'Nebbia', icon: '🌫️'),
    51 || 53 || 55 => (label: 'Pioviggine', icon: '🌦️'),
    61 || 63 || 65 => (label: 'Pioggia', icon: '🌧️'),
    71 || 73 || 75 => (label: 'Neve', icon: '❄️'),
    80 || 81 || 82 => (label: 'Rovesci', icon: '🌦️'),
    95 => (label: 'Temporale', icon: '⛈️'),
    96 || 99 => (label: 'Temporale con grandine', icon: '⛈️'),
    _ => (label: 'Non disponibile', icon: '🌡️'),
  };
}
