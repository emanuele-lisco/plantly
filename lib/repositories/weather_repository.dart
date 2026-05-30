import 'dart:convert';

import 'package:http/http.dart' as http;

import '../features/weather/weather_data.dart';

/// Repository che recupera i dati meteo da Open-Meteo.
///
/// Variabili richieste:
/// - current: temperature_2m, weather_code, relative_humidity_2m,
///            wind_speed_10m
/// - daily: temperature_2m_min, temperature_2m_max, weather_code,
///          precipitation_probability_max
///
/// forecast_days = 6 → oggi + 5 giorni futuri.
/// Il giorno corrente viene usato per min/max di oggi.
/// I giorni 1–5 alimentano WeatherData.forecast.
///
/// Questa logica è usata solo per la pagina meteo.
/// Non è collegata alla logica di irrigazione.
class WeatherRepository {
  WeatherRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<WeatherData> fetchWeather({
    required double latitude,
    required double longitude,
    required String city,
    required String countryName,
  }) async {
    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': latitude.toStringAsFixed(4),
        'longitude': longitude.toStringAsFixed(4),
        'current':
        'temperature_2m,weather_code,relative_humidity_2m,wind_speed_10m',
        'daily':
        'temperature_2m_min,temperature_2m_max,weather_code,'
            'precipitation_probability_max',
        'timezone': 'auto',
        'forecast_days': '6',
      },
    );

    try {
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw WeatherRepositoryException(
          'Errore HTTP ${response.statusCode} dal servizio meteo.',
        );
      }

      final decodedBody = jsonDecode(response.body);

      if (decodedBody is! Map<String, dynamic>) {
        throw const WeatherRepositoryException(
          'Risposta meteo non valida.',
        );
      }

      return _parseResponse(
        json: decodedBody,
        city: city,
        countryName: countryName,
      );
    } on WeatherRepositoryException {
      rethrow;
    } catch (_) {
      throw const WeatherRepositoryException(
        'Impossibile recuperare i dati meteo. Controlla la connessione.',
      );
    }
  }

  WeatherData _parseResponse({
    required Map<String, dynamic> json,
    required String city,
    required String countryName,
  }) {
    final current = json['current'];
    final daily = json['daily'];

    if (current is! Map<String, dynamic> ||
        daily is! Map<String, dynamic>) {
      throw const WeatherRepositoryException(
        'Struttura della risposta meteo non riconosciuta.',
      );
    }

    final tempCurrent = _readDouble(current['temperature_2m']);
    final weatherCodeRaw = current['weather_code'] ?? current['weathercode'];
    final weatherCode = _readInt(weatherCodeRaw);
    final humidity = _readInt(current['relative_humidity_2m']);
    final windSpeed = _readDouble(current['wind_speed_10m']);

    final timeList = daily['time'];
    final minList = daily['temperature_2m_min'];
    final maxList = daily['temperature_2m_max'];
    final codeList = daily['weather_code'] ?? daily['weathercode'];
    final precipList = daily['precipitation_probability_max'];

    final todayMin = minList is List && minList.isNotEmpty
        ? _readDouble(minList[0])
        : tempCurrent;

    final todayMax = maxList is List && maxList.isNotEmpty
        ? _readDouble(maxList[0])
        : tempCurrent;

    final todayPrecipitationProbability =
    precipList is List && precipList.isNotEmpty
        ? _readInt(precipList[0])
        : 0;

    final forecast = <DailyForecast>[];

    if (timeList is List &&
        minList is List &&
        maxList is List &&
        codeList is List) {
      for (var i = 1; i < timeList.length && i <= 5; i++) {
        final rawDate = timeList[i];

        final date = rawDate is String
            ? DateTime.tryParse(rawDate) ??
            DateTime.now().add(Duration(days: i))
            : DateTime.now().add(Duration(days: i));

        final minTemperature =
        i < minList.length ? _readDouble(minList[i]) : todayMin;

        final maxTemperature =
        i < maxList.length ? _readDouble(maxList[i]) : todayMax;

        final code = i < codeList.length ? _readInt(codeList[i]) : 0;
        final condition = weatherConditionFromCode(code);

        forecast.add(
          DailyForecast(
            date: date,
            minTemperatureCelsius: minTemperature,
            maxTemperatureCelsius: maxTemperature,
            condition: condition.label,
            conditionIcon: condition.icon,
          ),
        );
      }
    }

    final condition = weatherConditionFromCode(weatherCode);

    return WeatherData(
      city: city,
      countryName: countryName,
      temperatureCelsius: tempCurrent,
      minTemperatureCelsius: todayMin,
      maxTemperatureCelsius: todayMax,
      condition: condition.label,
      conditionIcon: condition.icon,
      humidity: humidity,
      windSpeedKmh: windSpeed,
      precipitationProbability: todayPrecipitationProbability,
      forecast: forecast,
      fetchedAt: DateTime.now(),
    );
  }

  static double _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class WeatherRepositoryException implements Exception {
  const WeatherRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}