import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../core/parse_from_json.dart';

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
      id: readString(json['id']),
      username: readString(json['username']),
      name: readString(json['name']),
      surname: readString(json['surname']),
      email: readString(json['email']),
      country: readString(json['country']),
      city: readString(json['city']),
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