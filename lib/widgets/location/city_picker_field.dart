import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/location/city_option.dart';
import '../../features/location/country_option.dart';
import '../../repositories/location_repository.dart';

/// Campo di ricerca città basato su Open-Meteo Geocoding API.
///
/// L'utente può digitare per cercare, ma il valore valido viene impostato solo
/// selezionando una città tra i risultati API.
class CityPickerField extends StatefulWidget {
  const CityPickerField({
    super.key,
    required this.country,
    required this.value,
    required this.onSelected,
    this.labelText = 'Città',
    this.helperText,
    this.enabled = true,
    this.repository,
    this.errorText,
  });

  final CountryOption? country;
  final CityOption? value;
  final ValueChanged<CityOption?> onSelected;
  final String labelText;
  final String? helperText;
  final bool enabled;
  final LocationRepository? repository;
  final String? errorText;

  @override
  State<CityPickerField> createState() => _CityPickerFieldState();
}

class _CityPickerFieldState extends State<CityPickerField> {
  late final LocationRepository _repository;
  late final TextEditingController _controller;
  Timer? _debounce;
  List<CityOption> _results = const [];
  bool _isLoading = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? LocationRepository();
    _controller = TextEditingController(text: widget.value?.name ?? '');
  }

  @override
  void didUpdateWidget(covariant CityPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.country?.code != widget.country?.code) {
      _controller.clear();
      _results = const [];
      _searchError = null;
    }

    final newName = widget.value?.name ?? '';
    if (newName.isNotEmpty && _controller.text != newName) {
      _controller.text = newName;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final country = widget.country;
    final canSearch = widget.enabled && country != null && country.code.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          enabled: canSearch,
          textCapitalization: TextCapitalization.words,
          onChanged: canSearch ? _onQueryChanged : null,
          decoration: InputDecoration(
            labelText: widget.labelText,
            helperText: widget.helperText ??
                (country == null ? 'Seleziona prima il paese.' : null),
            errorText: widget.errorText ?? _searchError,
            prefixIcon: const Icon(Icons.location_city_rounded),
            suffixIcon: _isLoading
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
        ),
        if (_results.isNotEmpty) ...[
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final city = _results[index];
                  return ListTile(
                    dense: true,
                    title: Text(city.label),
                    subtitle: Text(city.countryName),
                    onTap: () => _selectCity(city),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _onQueryChanged(String value) {
    widget.onSelected(null);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search(value);
    });
  }

  Future<void> _search(String query) async {
    final country = widget.country;
    if (country == null || query.trim().length < 2) {
      if (!mounted) return;
      setState(() {
        _results = const [];
        _searchError = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchError = null;
    });

    try {
      final results = await _repository.searchCities(
        query: query,
        countryCode: country.code,
      );
      if (!mounted) return;
      setState(() {
        _results = results;
        _searchError = results.isEmpty ? 'Nessuna città trovata.' : null;
      });
    } on LocationRepositoryException catch (e) {
      if (!mounted) return;
      setState(() {
        _results = const [];
        _searchError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _results = const [];
        _searchError = 'Errore durante la ricerca della città.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _selectCity(CityOption city) {
    _debounce?.cancel();
    setState(() {
      _controller.text = city.name;
      _results = const [];
      _searchError = null;
    });
    widget.onSelected(city);
  }
}
