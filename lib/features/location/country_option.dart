import 'package:equatable/equatable.dart';

/// Paese selezionabile nelle configurazioni Plantly.
///
/// I dati vengono caricati da API (REST Countries) e salvati con codice ISO.
/// Non usare input libero per il paese: serve un valore normalizzato per meteo
/// e logiche future lato app/backend.
class CountryOption extends Equatable {
  const CountryOption({
    required this.code,
    required this.name,
  });

  final String code;
  final String name;

  String get label => '$name ($code)';

  factory CountryOption.fromRestCountriesJson(Map<String, dynamic> json) {
    final code = (json['cca2'] as String? ?? '').trim().toUpperCase();
    final nameMap = json['name'];
    final translations = json['translations'];

    String name = '';
    if (translations is Map) {
      final italian = translations['ita'];
      if (italian is Map) {
        name = (italian['common'] as String? ?? '').trim();
      }
    }

    if (name.isEmpty && nameMap is Map) {
      name = (nameMap['common'] as String? ?? '').trim();
    }

    return CountryOption(code: code, name: name);
  }

  static CountryOption? fromValues({
    required String? countryCode,
    required String? countryName,
  }) {
    final code = countryCode?.trim().toUpperCase() ?? '';
    final name = countryName?.trim() ?? '';
    if (code.isEmpty && name.isEmpty) return null;
    return CountryOption(code: code, name: name.isEmpty ? code : name);
  }

  @override
  List<Object?> get props => [code, name];
}
