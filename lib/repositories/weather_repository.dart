import 'dart:convert';

import 'package:http/http.dart' as http;

import '../features/weather/weather_data.dart';

/// Repository che recupera i dati meteo da Open-Meteo.
///
/// Usa esclusivamente le variabili base:
/// - temperature_2m (attuale)
/// - temperature_2m_min / temperature_2m_max (giornaliere)
/// - weathercode (WMO code per condizione testuale)
///
/// Non calcola né restituisce nessun dato relativo all'irrigazione.
/// Non persiste dati su Firestore.
class WeatherRepository {
  WeatherRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Recupera i dati meteo per le coordinate fornite.
  ///
  /// Usa [latitude] e [longitude] per la chiamata API.
  /// [city] e [countryName] sono passati solo come label display nel model.
  ///
  /// Lancia [WeatherRepositoryException] in caso di errore HTTP o parsing.
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
        'current': 'temperature_2m,weathercode',
        'daily': 'temperature_2m_min,temperature_2m_max,weathercode',
        'timezone': 'auto',
        'forecast_days': '1',
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

      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) {
        throw const WeatherRepositoryException(
          'Risposta meteo non valida.',
        );
      }

      return _parseResponse(
        json: body,
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
    final current = json['current'] as Map<String, dynamic>?;
    final daily = json['daily'] as Map<String, dynamic>?;

    if (current == null || daily == null) {
      throw const WeatherRepositoryException(
        'Struttura della risposta meteo non riconosciuta.',
      );
    }

    final tempCurrent = _readDouble(current['temperature_2m']);
    final weatherCode = _readInt(current['weathercode']);

    final minList = daily['temperature_2m_min'];
    final maxList = daily['temperature_2m_max'];

    final tempMin = minList is List && minList.isNotEmpty
        ? _readDouble(minList.first)
        : tempCurrent;
    final tempMax = maxList is List && maxList.isNotEmpty
        ? _readDouble(maxList.first)
        : tempCurrent;

    final condition = weatherConditionFromCode(weatherCode);

    return WeatherData(
      city: city,
      countryName: countryName,
      temperatureCelsius: tempCurrent,
      minTemperatureCelsius: tempMin,
      maxTemperatureCelsius: tempMax,
      condition: condition.label,
      conditionIcon: condition.icon,
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
