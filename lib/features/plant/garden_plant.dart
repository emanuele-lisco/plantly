import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../core/parse_from_json.dart';

class GardenPlant extends Equatable {
  const GardenPlant({
    required this.id,
    required this.userId,
    required this.speciesId,
    required this.commonName,
    required this.scientificName,
    required this.nickname,
    required this.imageUrl,
    required this.watering,
    required this.sunlight,
    required this.indoor,
    required this.poisonousToHumans,
    required this.poisonousToPets,
    required this.addedAt,
    required this.updatedAt,
    this.lastWateredAt,
    this.nextWateringAt,
    this.notes = '',
    this.location = '',
    this.notificationEnabled = true,
    this.deviceId,
    this.smartPotId,
    this.targetMoistureMin = 35,
    this.targetMoistureMax = 65,
    this.potSize = 'medium',
    this.soilType = 'standard',
    this.drainageLevel = 'normal',
    this.plantSize = 'medium',
    this.exposure = 'indirect',
  });

  final String id;
  final String userId;
  final String speciesId;
  final String commonName;
  final String scientificName;
  final String nickname;
  final String imageUrl;
  final String watering;
  final List<String> sunlight;
  final bool? indoor;
  final bool poisonousToHumans;
  final bool poisonousToPets;
  final DateTime? addedAt;
  final DateTime? updatedAt;
  final DateTime? lastWateredAt;
  final DateTime? nextWateringAt;
  final String notes;
  final String location;

  final bool notificationEnabled;

  /// ID del dispositivo smart pot collegato alla pianta.
  ///
  /// `smartPotId` resta letto per compatibilità con documenti vecchi,
  /// ma la nuova struttura Firestore usa `deviceId`.
  final String? deviceId;

  // Campo legacy: usare `deviceId` nei nuovi documenti.
  final String? smartPotId;

  String? get linkedDeviceId {
    final current = deviceId?.trim() ?? '';
    if (current.isNotEmpty) return current;

    final legacy = smartPotId?.trim() ?? '';
    return legacy.isEmpty ? null : legacy;
  }

  bool get hasLinkedDevice => linkedDeviceId != null;


  final double targetMoistureMin;
  final double targetMoistureMax;
  final String potSize;
  final String soilType;
  final String drainageLevel;
  final String plantSize;
  final String exposure;

  String get displayName {
    final cleanNickname = nickname.trim();
    if (cleanNickname.isNotEmpty) return cleanNickname;

    final cleanCommonName = commonName.trim();
    if (cleanCommonName.isNotEmpty) return cleanCommonName;

    final cleanScientificName = scientificName.trim();
    if (cleanScientificName.isNotEmpty) return cleanScientificName;

    return 'Pianta senza nome';
  }

  factory GardenPlant.fromJson(Map<String, dynamic> json) {
    return GardenPlant(
      id: readString(json['id']),
      userId: readString(json['userId']),
      speciesId: readString(json['speciesId']),
      commonName: readString(json['commonName']),
      scientificName: readString(json['scientificName']),
      nickname: readString(json['nickname']),
      imageUrl: readString(json['imageUrl']),
      watering: readString(json['watering']),
      sunlight: readStringList(json['sunlight']),
      indoor: _readNullableBool(json['indoor']),
      poisonousToHumans: readBool(json['poisonousToHumans']),
      poisonousToPets: readBool(json['poisonousToPets']),
      addedAt: readDateTime(json['addedAt']),
      updatedAt: readDateTime(json['updatedAt']),
      lastWateredAt: readDateTime(json['lastWateredAt']),
      nextWateringAt: readDateTime(json['nextWateringAt']),
      notes: readString(json['notes']),
      location: readString(json['location']),
      notificationEnabled: readBool(json['notificationEnabled'], fallback: true),
      deviceId: readNullableString(json['deviceId']) ?? readNullableString(json['smartPotId']),
      smartPotId: readNullableString(json['smartPotId']),
      targetMoistureMin: readDouble(json['targetMoistureMin'], fallback: 35),
      targetMoistureMax: readDouble(json['targetMoistureMax'], fallback: 65),
      potSize: readString(json['potSize'], fallback: 'medium'),
      soilType: readString(json['soilType'], fallback: 'standard'),
      drainageLevel: readString(json['drainageLevel'], fallback: 'normal'),
      plantSize: readString(json['plantSize'], fallback: 'medium'),
      exposure: readString(json['exposure'], fallback: 'indirect'),
    );
  }

  factory GardenPlant.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    return GardenPlant.fromJson({
      ...?document.data(),
      'id': document.id,
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'speciesId': speciesId,
      'commonName': commonName,
      'scientificName': scientificName,
      'nickname': nickname,
      'imageUrl': imageUrl,
      'watering': watering,
      'sunlight': sunlight,
      'indoor': indoor,
      'poisonousToHumans': poisonousToHumans,
      'poisonousToPets': poisonousToPets,
      'addedAt': addedAt,
      'updatedAt': updatedAt,
      'lastWateredAt': lastWateredAt,
      'nextWateringAt': nextWateringAt,
      'notes': notes,
      'location': location,
      'notificationEnabled': notificationEnabled,
      'deviceId': linkedDeviceId,
      'smartPotId': smartPotId,
      'targetMoistureMin': targetMoistureMin,
      'targetMoistureMax': targetMoistureMax,
      'potSize': potSize,
      'soilType': soilType,
      'drainageLevel': drainageLevel,
      'plantSize': plantSize,
      'exposure': exposure,
    };
  }

  GardenPlant copyWith({
    String? id,
    String? userId,
    String? speciesId,
    String? commonName,
    String? scientificName,
    String? nickname,
    String? imageUrl,
    String? watering,
    List<String>? sunlight,
    bool? indoor,
    bool? poisonousToHumans,
    bool? poisonousToPets,
    DateTime? addedAt,
    DateTime? updatedAt,
    DateTime? lastWateredAt,
    DateTime? nextWateringAt,
    String? notes,
    String? location,
    bool? notificationEnabled,
    String? deviceId,
    String? smartPotId,
    double? targetMoistureMin,
    double? targetMoistureMax,
    String? potSize,
    String? soilType,
    String? drainageLevel,
    String? plantSize,
    String? exposure,
  }) {
    return GardenPlant(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      speciesId: speciesId ?? this.speciesId,
      commonName: commonName ?? this.commonName,
      scientificName: scientificName ?? this.scientificName,
      nickname: nickname ?? this.nickname,
      imageUrl: imageUrl ?? this.imageUrl,
      watering: watering ?? this.watering,
      sunlight: sunlight ?? this.sunlight,
      indoor: indoor ?? this.indoor,
      poisonousToHumans: poisonousToHumans ?? this.poisonousToHumans,
      poisonousToPets: poisonousToPets ?? this.poisonousToPets,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastWateredAt: lastWateredAt ?? this.lastWateredAt,
      nextWateringAt: nextWateringAt ?? this.nextWateringAt,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      deviceId: deviceId ?? this.deviceId,
      smartPotId: smartPotId ?? this.smartPotId,
      targetMoistureMin: targetMoistureMin ?? this.targetMoistureMin,
      targetMoistureMax: targetMoistureMax ?? this.targetMoistureMax,
      potSize: potSize ?? this.potSize,
      soilType: soilType ?? this.soilType,
      drainageLevel: drainageLevel ?? this.drainageLevel,
      plantSize: plantSize ?? this.plantSize,
      exposure: exposure ?? this.exposure,
    );
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
    userId,
    speciesId,
    commonName,
    scientificName,
    nickname,
    imageUrl,
    watering,
    sunlight,
    indoor,
    poisonousToHumans,
    poisonousToPets,
    addedAt,
    updatedAt,
    lastWateredAt,
    nextWateringAt,
    notes,
    location,
    notificationEnabled,
    deviceId,
    smartPotId,
    targetMoistureMin,
    targetMoistureMax,
    potSize,
    soilType,
    drainageLevel,
    plantSize,
    exposure,
  ];
}
