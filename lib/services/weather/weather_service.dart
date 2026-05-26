/// Interfaccia per la futura integrazione meteo.
///
/// La Fase 5 predispone soltanto il contratto: nessuna chiamata meteo reale
/// viene eseguita e nessun dato meteo viene inviato ad Arduino.
abstract class WeatherService {
  Future<DailyWeather?> getDailyWeather({
    required String countryCode,
    required String city,
    double? latitude,
    double? longitude,
  });
}

class DailyWeather {
  const DailyWeather({
    required this.date,
    required this.temperatureCelsius,
    this.minTemperatureCelsius,
    this.maxTemperatureCelsius,
    this.condition,
  });

  final DateTime date;
  final double temperatureCelsius;
  final double? minTemperatureCelsius;
  final double? maxTemperatureCelsius;
  final String? condition;
}

/// Implementazione placeholder usabile nei test o nella DI iniziale.
/// Restituisce sempre null perché il provider meteo reale non è ancora scelto.
class NoopWeatherService implements WeatherService {
  const NoopWeatherService();

  @override
  Future<DailyWeather?> getDailyWeather({
    required String countryCode,
    required String city,
    double? latitude,
    double? longitude,
  }) async {
    return null;
  }
}
