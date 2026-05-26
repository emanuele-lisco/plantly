import 'dart:convert';

import 'package:http/http.dart' as http;

import '../features/location/city_option.dart';
import '../features/location/country_option.dart';

class LocationRepository {
  LocationRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<CountryOption>> fetchCountries() async {
    final uri = Uri.https(
      'restcountries.com',
      '/v3.1/all',
      {
        'fields': 'name,cca2,translations',
      },
    );

    try {
      final response = await _client.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const LocationRepositoryException(
          'Errore durante il caricamento dei paesi.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) return const [];

      final countries = decoded
          .whereType<Map>()
          .map((item) => CountryOption.fromRestCountriesJson(
                Map<String, dynamic>.from(item),
              ))
          .where((country) => country.code.isNotEmpty && country.name.isNotEmpty)
          .toList(growable: false);

      final sorted = [...countries]
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      return sorted;
    } on LocationRepositoryException {
      rethrow;
    } catch (_) {
      throw const LocationRepositoryException(
        'Impossibile caricare la lista dei paesi.',
      );
    }
  }

  Future<List<CityOption>> searchCities({
    required String query,
    required String countryCode,
    int count = 10,
  }) async {
    final normalizedQuery = query.trim();
    final normalizedCountryCode = countryCode.trim().toUpperCase();

    if (normalizedQuery.length < 2 || normalizedCountryCode.isEmpty) {
      return const [];
    }

    final uri = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {
        'name': normalizedQuery,
        'count': count.toString(),
        'language': 'it',
        'format': 'json',
        'countryCode': normalizedCountryCode,
      },
    );

    try {
      final response = await _client.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const LocationRepositoryException(
          'Errore durante la ricerca della città.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return const [];

      final rawResults = decoded['results'];
      if (rawResults is! List) return const [];

      return rawResults
          .whereType<Map>()
          .map((item) => CityOption.fromOpenMeteoJson(
                Map<String, dynamic>.from(item),
              ))
          .where((city) => city.name.isNotEmpty)
          .toList(growable: false);
    } on LocationRepositoryException {
      rethrow;
    } catch (_) {
      throw const LocationRepositoryException(
        'Impossibile cercare la città.',
      );
    }
  }
}

class LocationRepositoryException implements Exception {
  const LocationRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
