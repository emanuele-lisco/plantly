import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/smart_pot_repository.dart';
import 'smart_pot_state.dart';

export 'smart_pot_state.dart';

class SmartPotCubit extends Cubit<SmartPotState> {
  SmartPotCubit({required SmartPotRepository smartPotRepository})
      : _smartPotRepository = smartPotRepository,
        super(const SmartPotInitial());

  final SmartPotRepository _smartPotRepository;
  StreamSubscription<dynamic>? _subscription;
  String? _currentDeviceId;

  void watchDevice(String? deviceId) {
    final trimmed = deviceId?.trim() ?? '';

    if (trimmed.isEmpty) {
      _cancelSubscription();
      _currentDeviceId = null;
      emit(const SmartPotNoDevice());
      return;
    }

    if (_currentDeviceId == trimmed && _subscription != null) return;

    _cancelSubscription();
    _currentDeviceId = trimmed;
    emit(const SmartPotLoading());

    _subscription = _smartPotRepository.watchDevice(trimmed).listen(
      (device) {
        if (device == null) {
          emit(
            const SmartPotFailure(
              message: 'Dispositivo non trovato su Firestore.',
            ),
          );
          return;
        }

        if (device.isOnline) {
          emit(SmartPotLoaded(device: device));
        } else {
          emit(SmartPotOffline(device: device));
        }
      },
      onError: (Object error) {
        final message = error is SmartPotRepositoryException
            ? error.message
            : 'Errore di connessione al dispositivo.';
        emit(SmartPotFailure(message: message));
      },
    );
  }

  Future<void> clear() async {
    await _cancelSubscription();
    _currentDeviceId = null;
    emit(const SmartPotInitial());
  }

  Future<void> _cancelSubscription() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  @override
  Future<void> close() async {
    await _cancelSubscription();
    return super.close();
  }
}
