import 'package:flutter/material.dart';

import '../../features/location/country_option.dart';
import '../../repositories/location_repository.dart';

/// Selettore paese basato su API REST Countries.
///
/// Non usa input libero: il valore finale è sempre un paese reale con codice ISO.
class CountryPickerField extends StatefulWidget {
  const CountryPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.labelText = 'Paese',
    this.helperText,
    this.enabled = true,
    this.repository,
    this.errorText,
  });

  final CountryOption? value;
  final ValueChanged<CountryOption?> onChanged;
  final String labelText;
  final String? helperText;
  final bool enabled;
  final LocationRepository? repository;
  final String? errorText;

  @override
  State<CountryPickerField> createState() => _CountryPickerFieldState();
}

class _CountryPickerFieldState extends State<CountryPickerField> {
  late final LocationRepository _repository;
  late Future<List<CountryOption>> _countriesFuture;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? LocationRepository();
    _countriesFuture = _repository.fetchCountries();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CountryOption>>(
      future: _countriesFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final countries = snapshot.data ?? const <CountryOption>[];
        final currentValue = _resolveCurrentValue(countries, widget.value);

        return DropdownButtonFormField<CountryOption>(
          initialValue: currentValue,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: widget.labelText,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: const Icon(Icons.public_rounded),
            suffixIcon: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          items: countries
              .map(
                (country) => DropdownMenuItem<CountryOption>(
                  value: country,
                  child: Text(country.label),
                ),
              )
              .toList(growable: false),
          onChanged: widget.enabled && countries.isNotEmpty ? widget.onChanged : null,
          validator: (country) {
            if (country == null) return 'Seleziona un paese.';
            return null;
          },
        );
      },
    );
  }

  CountryOption? _resolveCurrentValue(
    List<CountryOption> countries,
    CountryOption? value,
  ) {
    if (value == null || countries.isEmpty) return null;
    final code = value.code.trim().toUpperCase();
    if (code.isEmpty) return null;

    for (final country in countries) {
      if (country.code == code) return country;
    }

    return value.name.trim().isEmpty ? null : value;
  }
}
