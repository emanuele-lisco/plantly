import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/perenual_config.dart';
import '../features/plant/plant_species.dart';
import '../services/translation/plant_translation_service.dart';

class PlantRepository {
  PlantRepository({
    http.Client? client,
    String? apiKey,
    String? baseUrl,
    PlantTranslationService? translationService,
  })  : _client = client ?? http.Client(),
        _apiKey = apiKey ?? PerenualConfig.apiKey,
        _baseUrl = baseUrl ?? PerenualConfig.baseUrl,
        _translationService = translationService ?? PlantTranslationService();

  final http.Client _client;
  final String _apiKey;
  final String _baseUrl;
  final PlantTranslationService _translationService;

  Future<List<PlantSpecies>> searchPlants(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return const [];

    final uri = _buildUri(
      path: '/species-list',
      queryParameters: {'q': trimmedQuery},
    );

    final json = await _getJson(uri);
    final data = json['data'];

    if (data is! List) {
      throw const PlantRepositoryException(
        'Risposta non valida durante la ricerca delle piante.',
      );
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(PlantSpecies.fromPerenualJson)
        .toList(growable: false);
  }

  Future<PlantSpecies?> getPlantDetails(String speciesId) async {
    final trimmedId = speciesId.trim();
    if (trimmedId.isEmpty) return null;

    final uri = _buildUri(path: '/species/details/$trimmedId');
    final json = await _getJson(uri);

    final plant = PlantSpecies.fromPerenualJson(json);

    final description = plant.description.trim();
    if (description.isEmpty) return plant;

    final translatedDescription =
    await _translationService.translateEnToIt(description);

    return plant.copyWith(description: translatedDescription);
  }

  Uri _buildUri({
    required String path,
    Map<String, String> queryParameters = const {},
  }) {
    if (_apiKey.trim().isEmpty) {
      throw const PlantRepositoryException(
        'API key Perenual mancante. Avvia Flutter con --dart-define=PERENUAL_API_KEY=LA_TUA_KEY.',
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
        throw PlantRepositoryException(
          'Errore Perenual ${response.statusCode}: impossibile recuperare i dati delle piante.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;

      throw const PlantRepositoryException('Risposta Perenual non valida.');
    } on PlantRepositoryException {
      rethrow;
    } on TimeoutException {
      throw const PlantRepositoryException(
        'La ricerca sta impiegando troppo tempo. Riprova tra poco.',
      );
    } on FormatException {
      throw const PlantRepositoryException('Risposta Perenual non leggibile.');
    } catch (_) {
      throw const PlantRepositoryException(
        'Errore imprevisto durante la comunicazione con Perenual.',
      );
    }
  }
}

class PlantRepositoryException implements Exception {
  const PlantRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}