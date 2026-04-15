import 'package:equatable/equatable.dart';

class PlantlyUser extends Equatable {
  final String id;
  final String username;
  final String name;
  final String surname;
  final String email;
  final String country;
  final String city;
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
    this.imageUrl,
    this.bio,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$name $surname'.trim();

  String get usernameLowercase => username.trim().toLowerCase();

  PlantlyUser copyWith({
    String? id,
    String? username,
    String? name,
    String? surname,
    String? email,
    String? country,
    String? city,
    String? imageUrl,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlantlyUser(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      country: country ?? this.country,
      city: city ?? this.city,
      imageUrl: imageUrl ?? this.imageUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username.trim(),
      'username_lowercase': usernameLowercase,
      'name': name.trim(),
      'surname': surname.trim(),
      'email': email.trim(),
      'country': country.trim(),
      'city': city.trim(),
      'imageUrl': imageUrl,
      'bio': bio,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory PlantlyUser.fromJson(Map<String, dynamic> json) {
    return PlantlyUser(
      id: (json['id'] ?? '') as String,
      username: (json['username'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      surname: (json['surname'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      country: (json['country'] ?? '') as String,
      city: (json['city'] ?? '') as String,
      imageUrl: json['imageUrl'] as String?,
      bio: json['bio'] as String?,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
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
        city,
        imageUrl,
        bio,
        createdAt,
        updatedAt,
      ];
}
