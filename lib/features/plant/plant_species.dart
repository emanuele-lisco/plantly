import 'package:equatable/equatable.dart';



import '../../core/parse_from_json.dart';

class PlantSpecies extends Equatable {
  const PlantSpecies({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.watering,
    required this.sunlight,
    required this.indoor,
    required this.poisonousToHumans,
    required this.poisonousToPets,
    required this.imageThumbnailUrl,
    required this.imageSmallUrl,
    required this.imageMediumUrl,
    required this.imageOriginalUrl,
    this.description = '',
    this.careLevel = '',
    this.cycle = '',
    this.dimension = '',
  });

  final String id;
  final String commonName;
  final String scientificName;
  final String watering;
  final List<String> sunlight;
  final bool? indoor;
  final bool poisonousToHumans;
  final bool poisonousToPets;
  final String imageThumbnailUrl;
  final String imageSmallUrl;
  final String imageMediumUrl;
  final String imageOriginalUrl;
  final String description;
  final String careLevel;
  final String cycle;
  final String dimension;

  factory PlantSpecies.fromPerenualJson(Map<String, dynamic> json) {
    final scientificNames = readStringList(json['scientific_name']);
    final defaultImage = json['default_image'];
    final imageMap = defaultImage is Map<String, dynamic>
        ? defaultImage
        : const <String, dynamic>{};

    return PlantSpecies(
      id: readString(json['id']),
      commonName: readString(json['common_name'], fallback: 'Pianta senza nome'),
      scientificName: scientificNames.isNotEmpty
          ? scientificNames.first
          : readString(json['scientific_name'], fallback: readString(json['genus'])),
      watering: readString(json['watering']),
      sunlight: readStringList(json['sunlight']),
      indoor: _readNullableBool(json['indoor']),
      poisonousToHumans: readBool(json['poisonous_to_humans']),
      poisonousToPets: readBool(json['poisonous_to_pets']),
      imageThumbnailUrl: _sanitizeImageUrl(readString(imageMap['thumbnail'])),
      imageSmallUrl: _sanitizeImageUrl(readString(imageMap['small_url'])),
      imageMediumUrl: _sanitizeImageUrl(readString(imageMap['medium_url'])),
      imageOriginalUrl: _sanitizeImageUrl(readString(imageMap['original_url'])),
      description: readString(json['description']),
      careLevel: readString(json['care_level']),
      cycle: readString(json['cycle']),
      dimension: readString(json['dimension']),
    );
  }

  factory PlantSpecies.fromJson(Map<String, dynamic> json) {
    return PlantSpecies(
      id: readString(json['id']),
      commonName: readString(json['commonName']),
      scientificName: readString(json['scientificName']),
      watering: readString(json['watering']),
      sunlight: readStringList(json['sunlight']),
      indoor: _readNullableBool(json['indoor']),
      poisonousToHumans: readBool(json['poisonousToHumans']),
      poisonousToPets: readBool(json['poisonousToPets']),
      imageThumbnailUrl: _sanitizeImageUrl(readString(json['imageThumbnailUrl'])),
      imageSmallUrl: _sanitizeImageUrl(readString(json['imageSmallUrl'])),
      imageMediumUrl: _sanitizeImageUrl(readString(json['imageMediumUrl'])),
      imageOriginalUrl: _sanitizeImageUrl(readString(json['imageOriginalUrl'])),
      description: readString(json['description']),
      careLevel: readString(json['careLevel']),
      cycle: readString(json['cycle']),
      dimension: readString(json['dimension']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commonName': commonName,
      'scientificName': scientificName,
      'watering': watering,
      'sunlight': sunlight,
      'indoor': indoor,
      'poisonousToHumans': poisonousToHumans,
      'poisonousToPets': poisonousToPets,
      'imageThumbnailUrl': imageThumbnailUrl,
      'imageSmallUrl': imageSmallUrl,
      'imageMediumUrl': imageMediumUrl,
      'imageOriginalUrl': imageOriginalUrl,
      'description': description,
      'careLevel': careLevel,
      'cycle': cycle,
      'dimension': dimension,
    };
  }

  PlantSpecies copyWith({
    String? id,
    String? commonName,
    String? scientificName,
    String? watering,
    List<String>? sunlight,
    bool? indoor,
    bool? poisonousToHumans,
    bool? poisonousToPets,
    String? imageThumbnailUrl,
    String? imageSmallUrl,
    String? imageMediumUrl,
    String? imageOriginalUrl,
    String? description,
    String? careLevel,
    String? cycle,
    String? dimension,
  }) {
    return PlantSpecies(
      id: id ?? this.id,
      commonName: commonName ?? this.commonName,
      scientificName: scientificName ?? this.scientificName,
      watering: watering ?? this.watering,
      sunlight: sunlight ?? this.sunlight,
      indoor: indoor ?? this.indoor,
      poisonousToHumans: poisonousToHumans ?? this.poisonousToHumans,
      poisonousToPets: poisonousToPets ?? this.poisonousToPets,
      imageThumbnailUrl: imageThumbnailUrl ?? this.imageThumbnailUrl,
      imageSmallUrl: imageSmallUrl ?? this.imageSmallUrl,
      imageMediumUrl: imageMediumUrl ?? this.imageMediumUrl,
      imageOriginalUrl: imageOriginalUrl ?? this.imageOriginalUrl,
      description: description ?? this.description,
      careLevel: careLevel ?? this.careLevel,
      cycle: cycle ?? this.cycle,
      dimension: dimension ?? this.dimension,
    );
  }

  String get imageUrl {
    if (imageMediumUrl.isNotEmpty) return imageMediumUrl;
    if (imageSmallUrl.isNotEmpty) return imageSmallUrl;
    if (imageThumbnailUrl.isNotEmpty) return imageThumbnailUrl;
    if (imageOriginalUrl.isNotEmpty) return imageOriginalUrl;
    return '';
  }

  String get heroImageUrl {
    if (imageOriginalUrl.isNotEmpty) return imageOriginalUrl;
    if (imageMediumUrl.isNotEmpty) return imageMediumUrl;
    if (imageSmallUrl.isNotEmpty) return imageSmallUrl;
    if (imageThumbnailUrl.isNotEmpty) return imageThumbnailUrl;
    return '';
  }

  bool get hasUsefulImage => heroImageUrl.isNotEmpty;

  static String _sanitizeImageUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.contains('upgrade_access.jpg')) return '';
    return trimmed;
  }

  static bool? _readNullableBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
        return true;
      }
      if (normalized == 'false' || normalized == '0' || normalized == 'no') {
        return false;
      }
    }
    return null;
  }


  @override
  List<Object?> get props => [
        id,
        commonName,
        scientificName,
        watering,
        sunlight,
        indoor,
        poisonousToHumans,
        poisonousToPets,
        imageThumbnailUrl,
        imageSmallUrl,
        imageMediumUrl,
        imageOriginalUrl,
        description,
        careLevel,
        cycle,
        dimension,
      ];
}
