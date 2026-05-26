import 'package:equatable/equatable.dart';

import '../../core/parse_from_json.dart';

class UserPlant extends Equatable {
  final String id;
  final String speciesId;
  final String name;
  final String species;
  final String room;
  final int moisture;
  final int light;
  final int health;
  final String nextAction;
  final String imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// ID del dispositivo smart pot collegato a questa pianta.
  /// Null se la pianta non ha ancora un vaso intelligente associato.
  final String? deviceId;

  const UserPlant({
    required this.id,
    required this.speciesId,
    required this.name,
    required this.species,
    required this.room,
    required this.moisture,
    required this.light,
    required this.health,
    required this.nextAction,
    required this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.deviceId,
  });

  bool get hasDevice => deviceId != null && deviceId!.trim().isNotEmpty;

  UserPlant copyWith({
    String? id,
    String? speciesId,
    String? name,
    String? species,
    String? room,
    int? moisture,
    int? light,
    int? health,
    String? nextAction,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deviceId,
    bool clearDeviceId = false,
  }) {
    return UserPlant(
      id: id ?? this.id,
      speciesId: speciesId ?? this.speciesId,
      name: name ?? this.name,
      species: species ?? this.species,
      room: room ?? this.room,
      moisture: moisture ?? this.moisture,
      light: light ?? this.light,
      health: health ?? this.health,
      nextAction: nextAction ?? this.nextAction,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: clearDeviceId ? null : deviceId ?? this.deviceId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speciesId': speciesId,
      'name': name,
      'species': species,
      'room': room,
      'moisture': moisture,
      'light': light,
      'health': health,
      'nextAction': nextAction,
      'imageUrl': imageUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deviceId': deviceId,
    };
  }

  factory UserPlant.fromJson(Map<String, dynamic> json) {
    return UserPlant(
      id: readString(json['id']),
      speciesId: readString(json['speciesId']),
      name: readString(json['name']),
      species: readString(json['species']),
      room: readString(json['room']),
      moisture: readInt(json['moisture']),
      light: readInt(json['light']),
      health: readInt(json['health']),
      nextAction: readString(json['nextAction']),
      imageUrl: readString(json['imageUrl']),
      createdAt: readDateTime(json['createdAt']),
      updatedAt: readDateTime(json['updatedAt']),
      deviceId: readNullableString(json['deviceId']),
    );
  }

  factory UserPlant.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return UserPlant.fromJson({
      ...data,
      'id': id,
    });
  }

  @override
  List<Object?> get props => [
        id,
        speciesId,
        name,
        species,
        room,
        moisture,
        light,
        health,
        nextAction,
        imageUrl,
        createdAt,
        updatedAt,
        deviceId,
      ];
}
