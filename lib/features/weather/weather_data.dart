import 'package:equatable/equatable.dart';

/// Singola giornata della previsione meteo a 5 giorni.
class DailyForecast extends Equatable {
  const DailyForecast({
    required this.date,
    required this.minTemperatureCelsius,
    required this.maxTemperatureCelsius,
    required this.condition,
    required this.conditionIcon,
  });

  final DateTime date;
  final double minTemperatureCelsius;
  final double maxTemperatureCelsius;

  /// Descrizione testuale della condizione, es. "Sereno", "Pioggia".
  final String condition;

  /// Icona testuale associata alla condizione meteo.
  final String conditionIcon;

  String get minDisplay => '${minTemperatureCelsius.toStringAsFixed(0)}°';

  String get maxDisplay => '${maxTemperatureCelsius.toStringAsFixed(0)}°';

  String get dayLabel {
    const days = [
      'Lunedì',
      'Martedì',
      'Mercoledì',
      'Giovedì',
      'Venerdì',
      'Sabato',
      'Domenica',
    ];

    return days[date.weekday - 1];
  }

  @override
  List<Object?> get props => [
    date,
    minTemperatureCelsius,
    maxTemperatureCelsius,
    condition,
    conditionIcon,
  ];
}

/// Dati meteo giornalieri restituiti da Open-Meteo.
///
/// Usato esclusivamente per la visualizzazione nella WeatherPage.
/// Non è collegato alla logica di irrigazione.
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
    this.humidity = 0,
    this.windSpeedKmh = 0.0,
    this.precipitationProbability = 0,
    this.forecast = const [],
  });

  final String city;
  final String countryName;
  final double temperatureCelsius;
  final double minTemperatureCelsius;
  final double maxTemperatureCelsius;
  final String condition;
  final String conditionIcon;
  final DateTime fetchedAt;
  final int humidity;
  final double windSpeedKmh;
  final int precipitationProbability;

  /// Previsione per i prossimi 5 giorni, escluso oggi.
  final List<DailyForecast> forecast;

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
    humidity,
    windSpeedKmh,
    precipitationProbability,
    forecast,
    fetchedAt,
  ];
}

/// Mappa i WMO Weather Interpretation Codes di Open-Meteo
/// in descrizione testuale italiana.
///
/// Ref: Open-Meteo Weather Interpretation Codes.
({String label, String icon}) weatherConditionFromCode(int code) {
  return switch (code) {
    0 => (label: 'Sereno', icon: '☀️'),
    1 => (label: 'Principalmente sereno', icon: '🌤️'),
    2 => (label: 'Parzialmente nuvoloso', icon: '⛅'),
    3 => (label: 'Coperto', icon: '☁️'),
    45 || 48 => (label: 'Nebbia', icon: '🌫️'),
    51 || 53 || 55 => (label: 'Pioviggine', icon: '🌦️'),
    56 || 57 => (label: 'Pioviggine gelata', icon: '🌧️'),
    61 || 63 || 65 => (label: 'Pioggia', icon: '🌧️'),
    66 || 67 => (label: 'Pioggia gelata', icon: '🌧️'),
    71 || 73 || 75 => (label: 'Neve', icon: '❄️'),
    77 => (label: 'Nevischio', icon: '❄️'),
    80 || 81 || 82 => (label: 'Rovesci', icon: '🌦️'),
    85 || 86 => (label: 'Rovesci nevosi', icon: '🌨️'),
    95 => (label: 'Temporale', icon: '⛈️'),
    96 || 99 => (label: 'Temporale con grandine', icon: '⛈️'),
    _ => (label: 'Non disponibile', icon: '—'),
  };
}