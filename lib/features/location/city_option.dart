import 'package:equatable/equatable.dart';

import '../../core/parse_from_json.dart';

/// Città selezionata da API di geocoding.
///
/// Le coordinate restano lato app/backend e serviranno in futuro per meteo e
/// calcolo irrigazione. Non vengono inviate ad Arduino.
class CityOption extends Equatable {
  const CityOption({
    required this.name,
    required this.countryCode,
    required this.countryName,
    this.latitude,
    this.longitude,
    this.admin1,
  });

  final String name;
  final String countryCode;
  final String countryName;
  final double? latitude;
  final double? longitude;
  final String? admin1;

  String get label {
    final region = admin1?.trim() ?? '';
    if (region.isNotEmpty) return '$name, $region';
    return name;
  }

  factory CityOption.fromOpenMeteoJson(Map<String, dynamic> json) {
    return CityOption(
      name: readString(json['name']),
      countryCode: readString(json['country_code']).toUpperCase(),
      countryName: readString(json['country']),
      latitude: _readNullableDouble(json['latitude']),
      longitude: _readNullableDouble(json['longitude']),
      admin1: readNullableString(json['admin1']),
    );
  }

  static double? _readNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  @override
  List<Object?> get props => [
        name,
        countryCode,
        countryName,
        latitude,
        longitude,
        admin1,
      ];
}
