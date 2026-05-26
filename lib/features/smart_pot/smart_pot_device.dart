import 'package:equatable/equatable.dart';

import '../../core/parse_from_json.dart';

class SmartPotDevice extends Equatable {
  final String id;
  final String userId;
  final String gardenPlantId;
  final String name;
  final String deviceCode;
  final bool isLinked;
  final bool isOnline;
  final DateTime? lastSeenAt;
  final String firmwareVersion;
  final int moistureRaw;
  final double moisturePercent;
  final double lightLux;
  final double waterReservoirMl;
  final double pumpMlPerSecond;
  final DateTime? lastIrrigationAt;
  final double totalPumpRuntimeSeconds;

  const SmartPotDevice({
    required this.id,
    required this.userId,
    required this.gardenPlantId,
    required this.name,
    required this.deviceCode,
    required this.isLinked,
    required this.isOnline,
    required this.lastSeenAt,
    required this.firmwareVersion,
    required this.moistureRaw,
    required this.moisturePercent,
    required this.lightLux,
    required this.waterReservoirMl,
    required this.pumpMlPerSecond,
    required this.lastIrrigationAt,
    required this.totalPumpRuntimeSeconds,
  });

  const SmartPotDevice.empty()
      : id = '',
        userId = '',
        gardenPlantId = '',
        name = '',
        deviceCode = '',
        isLinked = false,
        isOnline = false,
        lastSeenAt = null,
        firmwareVersion = '',
        moistureRaw = 0,
        moisturePercent = 0,
        lightLux = 0,
        waterReservoirMl = 0,
        pumpMlPerSecond = 0,
        lastIrrigationAt = null,
        totalPumpRuntimeSeconds = 0;

  SmartPotDevice copyWith({
    String? id,
    String? userId,
    String? gardenPlantId,
    String? name,
    String? deviceCode,
    bool? isLinked,
    bool? isOnline,
    DateTime? lastSeenAt,
    bool clearLastSeenAt = false,
    String? firmwareVersion,
    int? moistureRaw,
    double? moisturePercent,
    double? lightLux,
    double? waterReservoirMl,
    double? pumpMlPerSecond,
    DateTime? lastIrrigationAt,
    bool clearLastIrrigationAt = false,
    double? totalPumpRuntimeSeconds,
  }) {
    return SmartPotDevice(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gardenPlantId: gardenPlantId ?? this.gardenPlantId,
      name: name ?? this.name,
      deviceCode: deviceCode ?? this.deviceCode,
      isLinked: isLinked ?? this.isLinked,
      isOnline: isOnline ?? this.isOnline,
      lastSeenAt: clearLastSeenAt ? null : lastSeenAt ?? this.lastSeenAt,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      moistureRaw: moistureRaw ?? this.moistureRaw,
      moisturePercent: moisturePercent ?? this.moisturePercent,
      lightLux: lightLux ?? this.lightLux,
      waterReservoirMl: waterReservoirMl ?? this.waterReservoirMl,
      pumpMlPerSecond: pumpMlPerSecond ?? this.pumpMlPerSecond,
      lastIrrigationAt: clearLastIrrigationAt
          ? null
          : lastIrrigationAt ?? this.lastIrrigationAt,
      totalPumpRuntimeSeconds:
          totalPumpRuntimeSeconds ?? this.totalPumpRuntimeSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'gardenPlantId': gardenPlantId,
      'name': name,
      'deviceCode': deviceCode,
      'isLinked': isLinked,
      'isOnline': isOnline,
      'lastSeenAt': lastSeenAt?.toIso8601String(),
      'firmwareVersion': firmwareVersion,
      'moistureRaw': moistureRaw,
      'moisturePercent': moisturePercent,
      'lightLux': lightLux,
      'waterReservoirMl': waterReservoirMl,
      'pumpMlPerSecond': pumpMlPerSecond,
      'lastIrrigationAt': lastIrrigationAt?.toIso8601String(),
      'totalPumpRuntimeSeconds': totalPumpRuntimeSeconds,
    };
  }

  factory SmartPotDevice.fromJson(Map<String, dynamic> json) {
    return SmartPotDevice(
      id: readString(json['id']),
      userId: readString(json['userId']),
      gardenPlantId: readString(json['gardenPlantId']),
      name: readString(json['name'], fallback: 'Vaso intelligente'),
      deviceCode: readString(json['deviceCode']),
      isLinked: readBool(json['isLinked']),
      isOnline: readBool(json['isOnline']),
      lastSeenAt: readDateTime(json['lastSeenAt']),
      firmwareVersion: readString(json['firmwareVersion']),
      moistureRaw: readInt(json['moistureRaw']),
      moisturePercent: readDouble(json['moisturePercent']),
      lightLux: readDouble(json['lightLux']),
      waterReservoirMl: readDouble(json['waterReservoirMl']),
      pumpMlPerSecond: readDouble(json['pumpMlPerSecond']),
      lastIrrigationAt: readDateTime(json['lastIrrigationAt']),
      totalPumpRuntimeSeconds: readDouble(json['totalPumpRuntimeSeconds']),
    );
  }

  factory SmartPotDevice.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return SmartPotDevice.fromJson({
      ...data,
      'id': id,
    });
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        gardenPlantId,
        name,
        deviceCode,
        isLinked,
        isOnline,
        lastSeenAt,
        firmwareVersion,
        moistureRaw,
        moisturePercent,
        lightLux,
        waterReservoirMl,
        pumpMlPerSecond,
        lastIrrigationAt,
        totalPumpRuntimeSeconds,
      ];
}
