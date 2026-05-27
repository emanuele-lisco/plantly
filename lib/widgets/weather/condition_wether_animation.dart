import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

const _nebbia = 'assets/lotties/nebbia.json';
const _neve = 'assets/lotties/neve.json';
const _notte = 'assets/lotties/notte.json';
const _nuvoloso = 'assets/lotties/nuvoloso.json';
const _parzialmenteNuvoloso = 'assets/lotties/parzialmente_nuvoloso.json';
const _pioggia = 'assets/lotties/pioggia.json';
const _pioggiaNotte = 'assets/lotties/pioggia_notte.json';
const _pioviggine = 'assets/lotties/pioviggine.json';
const _soleggiato1 = 'assets/lotties/soleggiato1.json';
const _soleggiato2 = 'assets/lotties/soleggiato2.json';
const _temporale = 'assets/lotties/temporale.json';
const _tuoni = 'assets/lotties/tuoni.json';
const _vento = 'assets/lotties/vento.json';

const _height = 70.0;
const _width = 70.0;

class WeatherAnimation extends StatelessWidget {
  const WeatherAnimation({
    super.key,
    required this.condition,
    this.dt,
  });

  final String condition;
  final DateTime? dt;

  bool get _isNight {
    final hour = dt?.hour ?? DateTime.now().hour;
    return hour < 6 || hour >= 20;
  }

  @override
  Widget build(BuildContext context) {
    final animationPath = switch (condition) {
      'Sereno' => _isNight ? _notte : _soleggiato1,
      'Principalmente sereno' => _isNight ? _notte : _soleggiato2,
      'Parzialmente nuvoloso' =>
      _isNight ? _notte : _parzialmenteNuvoloso,
      'Coperto' => _nuvoloso,
      'Nebbia' => _nebbia,
      'Pioviggine' => _pioviggine,
      'Pioggia' => _isNight ? _pioggiaNotte : _pioggia,
      'Neve' => _neve,
      'Rovesci' => _isNight ? _pioggiaNotte : _pioggia,
      'Temporale' => _temporale,
      'Temporale con grandine' => _temporale,
      'Vento' => _vento,
      _ => _soleggiato1,
    };

    return Lottie.asset(
      animationPath,
      height: _height,
      width: _width,
      fit: BoxFit.contain,
      repeat: true,
      animate: true,
    );
  }
}