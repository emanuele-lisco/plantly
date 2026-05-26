import 'package:equatable/equatable.dart';

import '../../core/parse_from_json.dart';

class PlantlyUser extends Equatable {
  final String id;
  final String username;
  final String name;
  final String surname;
  final String email;

  /// Nome paese legacy/display. Nei nuovi documenti coincide con [countryName].
  final String country;

  /// Codice ISO del paese selezionato tramite API.
  final String countryCode;

  /// Nome normalizzato del paese selezionato tramite API.
  final String countryName;

  /// Città selezionata tramite geocoding API.
  final String city;

  /// Coordinate della città, usate in futuro per meteo e irrigazione lato app/backend.
  final double? latitude;
  final double? longitude;

  final String? imageUrl;
  final String? bio;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PlantlyUser({
    required this.id,
    required this.username,
    required this.name,
    required this.surname,
    required this.email,
    required this.country,
    required this.city,
    this.countryCode = '',
    String? countryName,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.bio,
    this.createdAt,
    this.updatedAt,
  }) : countryName = countryName ?? country;

  String get fullName => '$name $surname'.trim();

  String get usernameLowercase => username.trim().toLowerCase();

  String get locationLabel {
    final parts = [
      if (city.trim().isNotEmpty) city.trim(),
      if (countryName.trim().isNotEmpty) countryName.trim(),
    ];
    return parts.join(', ');
  }

  PlantlyUser copyWith({
    String? id,
    String? username,
    String? name,
    String? surname,
    String? email,
    String? country,
    String? countryCode,
    String? countryName,
    String? city,
    double? latitude,
    double? longitude,
    bool clearLatitude = false,
    bool clearLongitude = false,
    String? imageUrl,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final nextCountryName = countryName ?? country ?? this.countryName;
    return PlantlyUser(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      country: nextCountryName,
      countryCode: countryCode ?? this.countryCode,
      countryName: nextCountryName,
      city: city ?? this.city,
      latitude: clearLatitude ? null : latitude ?? this.latitude,
      longitude: clearLongitude ? null : longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    final normalizedCountryName = countryName.trim().isNotEmpty
        ? countryName.trim()
        : country.trim();

    return {
      'id': id,
      'username': username.trim(),
      'username_lowercase': usernameLowercase,
      'name': name.trim(),
      'surname': surname.trim(),
      'email': email.trim(),
      'country': normalizedCountryName,
      'countryCode': countryCode.trim().toUpperCase(),
      'countryName': normalizedCountryName,
      'city': city.trim(),
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'bio': bio,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory PlantlyUser.fromJson(Map<String, dynamic> json) {
    final countryName = readString(
      json['countryName'],
      fallback: readString(json['country']),
    );

    return PlantlyUser(
      id: readString(json['id']),
      username: readString(json['username']),
      name: readString(json['name']),
      surname: readString(json['surname']),
      email: readString(json['email']),
      country: countryName,
      countryCode: readString(json['countryCode']).toUpperCase(),
      countryName: countryName,
      city: readString(json['city']),
      latitude: _readNullableDouble(json['latitude']),
      longitude: _readNullableDouble(json['longitude']),
      imageUrl: readNullableString(json['imageUrl']),
      bio: readNullableString(json['bio']),
      createdAt: readDateTime(json['createdAt']),
      updatedAt: readDateTime(json['updatedAt']),
    );
  }

  factory PlantlyUser.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return PlantlyUser.fromJson({
      ...data,
      'id': id,
    });
  }

  static double? _readNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        username,
        name,
        surname,
        email,
        country,
        countryCode,
        countryName,
        city,
        latitude,
        longitude,
        imageUrl,
        bio,
        createdAt,
        updatedAt,
      ];
}
