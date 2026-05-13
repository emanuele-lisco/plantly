import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:plantly_app/core/parse_from_json.dart';
import 'package:plantly_app/core/perenual_config.dart';

import '../features/plant/plant_species.dart';

class PlantSpeciesRepository {
  PlantSpeciesRepository({
    http.Client? client,
    String? apiKey,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _apiKey = apiKey ?? PerenualConfig.apiKey,
        _baseUrl = baseUrl ?? PerenualConfig.baseUrl;

  final http.Client _client;
  final String _apiKey;
  final String _baseUrl;

  Future<PlantSpeciesSearchResult> searchPlants({
    required String query,
    int page = 1,
    bool? indoor,
    String? watering,
    String? sunlight,
  }) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      return const PlantSpeciesSearchResult.empty();
    }

    final uri = _buildUri(
      path: '/species-list',
      queryParameters: {
        'page': page.toString(),
        'q': trimmedQuery,
        if (indoor != null) 'indoor': indoor ? '1' : '0',
        if (watering != null && watering.trim().isNotEmpty)
          'watering': watering.trim(),
        if (sunlight != null && sunlight.trim().isNotEmpty)
          'sunlight': sunlight.trim(),
      },
    );

    final json = await _getJson(uri);
    final data = json['data'];

    if (data is! List) {
      throw const PlantSpeciesRepositoryException(
        'Risposta non valida durante la ricerca delle piante',
      );
    }

    final plants = data
        .whereType<Map<String, dynamic>>()
        .map(PlantSpecies.fromPerenualJson)
        .toList(growable: false);

    return PlantSpeciesSearchResult(
      plants: plants,
      currentPage: readInt(json['current_page'], fallback: page),
      lastPage: readInt(json['last_page'], fallback: page),
      total: readInt(json['total'], fallback: plants.length),
    );
  }

  Future<PlantSpecies> getPlantDetails(String speciesId) async {
    final trimmedId = speciesId.trim();

    if (trimmedId.isEmpty) {
      throw const PlantSpeciesRepositoryException('ID pianta non valido');
    }

    final uri = _buildUri(path: '/species/details/$trimmedId');
    final json = await _getJson(uri);

    return PlantSpecies.fromPerenualJson(json);
  }

  Uri _buildUri({
    required String path,
    Map<String, String> queryParameters = const {},
  }) {
    if (_apiKey.trim().isEmpty) {
      throw const PlantSpeciesRepositoryException(
        'API key Perenual mancante. Avvia Flutter con --dart-define=PERENUAL_API_KEY=LA_TUA_KEY',
      );
    }

    final base = Uri.parse(_baseUrl);
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    return base.replace(
      path: '${base.path}$normalizedPath'.replaceAll('//', '/'),
      queryParameters: {
        'key': _apiKey,
        ...queryParameters,
      },
    );
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw PlantSpeciesRepositoryException(
          'Errore Perenual ${response.statusCode}: impossibile recuperare i dati delle piante',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw const PlantSpeciesRepositoryException(
        'Risposta Perenual non valida',
      );
    } on PlantSpeciesRepositoryException {
      rethrow;
    } on TimeoutException {
      throw const PlantSpeciesRepositoryException(
        'La ricerca sta impiegando troppo tempo. Riprova tra poco.',
      );
    } on FormatException {
      throw const PlantSpeciesRepositoryException(
        'Risposta Perenual non leggibile',
      );
    } catch (_) {
      throw const PlantSpeciesRepositoryException(
        'Errore imprevisto durante la comunicazione con Perenual',
      );
    }
  }
}

class PlantSpeciesSearchResult {
  const PlantSpeciesSearchResult({
    required this.plants,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  const PlantSpeciesSearchResult.empty()
      : plants = const [],
        currentPage = 1,
        lastPage = 1,
        total = 0;

  final List<PlantSpecies> plants;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasMore => currentPage < lastPage;
}

class PlantSpeciesRepositoryException implements Exception {
  const PlantSpeciesRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}