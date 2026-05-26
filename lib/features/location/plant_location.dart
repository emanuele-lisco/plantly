import 'package:equatable/equatable.dart';

import '../../core/parse_from_json.dart';

/// Configurazione geografica della pianta.
///
/// Questi dati restano lato app/backend e non vengono inviati ad Arduino.
/// Serviranno alla futura logica meteo per adattare i consigli di irrigazione.
class PlantLocation extends Equatable {
  const PlantLocation({
    required this.countryCode,
    required this.countryName,
    required this.city,
    this.latitude,
    this.longitude,
  });

  final String countryCode;
  final String countryName;
  final String city;
  final double? latitude;
  final double? longitude;

  bool get hasCountry => countryCode.trim().isNotEmpty;
  bool get hasCity => city.trim().isNotEmpty;

  String get displayLabel {
    final parts = [
      if (city.trim().isNotEmpty) city.trim(),
      if (countryName.trim().isNotEmpty) countryName.trim(),
    ];
    return parts.join(', ');
  }

  PlantLocation copyWith({
    String? countryCode,
    String? countryName,
    String? city,
    double? latitude,
    double? longitude,
    bool clearLatitude = false,
    bool clearLongitude = false,
  }) {
    return PlantLocation(
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      city: city ?? this.city,
      latitude: clearLatitude ? null : latitude ?? this.latitude,
      longitude: clearLongitude ? null : longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode.trim().toUpperCase(),
      'countryName': countryName.trim(),
      'city': city.trim(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory PlantLocation.fromJson(Map<String, dynamic> json) {
    return PlantLocation(
      countryCode: readString(json['countryCode']).toUpperCase(),
      countryName: readString(json['countryName']),
      city: readString(json['city']),
      latitude: _readNullableDouble(json['latitude']),
      longitude: _readNullableDouble(json['longitude']),
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
        countryCode,
        countryName,
        city,
        latitude,
        longitude,
      ];
}
