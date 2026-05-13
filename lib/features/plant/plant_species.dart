import 'package:equatable/equatable.dart';

import '../../core/parse_from_json.dart';

class PlantSpecies extends Equatable {
  final String id;
  final String commonName;
  final String scientificName;
  final String imageUrl;
  final String watering;
  final List<String> sunlight;
  final bool indoor;
  final bool poisonousToHumans;
  final bool poisonousToPets;

  const PlantSpecies({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.imageUrl,
    required this.watering,
    required this.sunlight,
    required this.indoor,
    required this.poisonousToHumans,
    required this.poisonousToPets,
  });

  factory PlantSpecies.fromPerenualJson(Map<String, dynamic> json) {
    return PlantSpecies(
      id: readString(json['id']),
      commonName: readString(json['common_name']),
      scientificName: readString(json['scientific_name']),
      imageUrl: readString(json['default_image']),
      watering: readString(json['watering']),
      sunlight: readStringList(json['sunlight']),
      indoor: readBool(json['indoor']),
      poisonousToHumans: readBool(json['poisonous_to_humans']),
      poisonousToPets: readBool(json['poisonous_to_pets']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        commonName,
        scientificName,
        imageUrl,
        watering,
        sunlight,
        indoor,
        poisonousToHumans,
        poisonousToPets,
      ];
}
