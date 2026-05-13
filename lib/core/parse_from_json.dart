import 'package:cloud_firestore/cloud_firestore.dart';

String readString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  if (value is String) return value.trim();
  if (value is num || value is bool) return value.toString();
  return fallback;
}

String? readNullableString(dynamic value) {
  final parsed = readString(value);
  return parsed.isEmpty ? null : parsed;
}

int readInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? fallback;
  return fallback;
}

double readDouble(dynamic value, {double fallback = 0}) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? fallback;
  return fallback;
}

bool readBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value == 1;

  if (value is String) {
    final normalized = value.toLowerCase().trim();
    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes' ||
        normalized == 'y';
  }

  return fallback;
}

List<String> readStringList(dynamic value) {
  if (value == null) return const [];

  if (value is List) {
    return value
        .map(readString)
        .where((element) => element.trim().isNotEmpty)
        .toList(growable: false);
  }

  final singleValue = readString(value);
  return singleValue.isEmpty ? const [] : [singleValue];
}

DateTime? readDateTime(dynamic value) {
  if (value == null) return null;

  if (value is Timestamp) {
    return value.toDate().toUtc();
  }

  if (value is DateTime) {
    return value.toUtc();
  }

  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value.trim())?.toUtc();
  }

  try {
    final dynamic date = value.toDate();
    if (date is DateTime) return date.toUtc();
  } catch (_) {}

  return null;
}