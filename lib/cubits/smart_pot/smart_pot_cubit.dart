import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/smart_pot_repository.dart';
import 'smart_pot_state.dart';

class SmartPotCubit extends Cubit<SmartPotState> {
  SmartPotCubit({required SmartPotRepository smartPotRepository})
      : _smartPotRepository = smartPotRepository,
        super(const SmartPotInitial());

  final SmartPotRepository _smartPotRepository;
  StreamSubscription? _deviceSubscription;

  void watchDevice({required String userId, required String deviceId}) {
    final safeUserId = userId.trim();
    final safeDeviceId = deviceId.trim();

    if (safeUserId.isEmpty || safeDeviceId.isEmpty) {
      emit(
        const SmartPotFailure(
          message: 'Utente o dispositivo smart pot non disponibile.',
        ),
      );
      return;
    }

    emit(SmartPotLoading(device: state.device));
    _deviceSubscription?.cancel();
    _deviceSubscription = _smartPotRepository
        .watchDevice(safeUserId, safeDeviceId)
        .listen(
          (device) {
            if (device == null || !device.isLinked) {
              emit(
                const SmartPotDisconnected(
                  message: 'Nessun vaso intelligente collegato.',
                ),
              );
              return;
            }

            if (device.isOnline) {
              emit(SmartPotConnected(device: device));
            } else {
              emit(
                SmartPotDisconnected(
                  device: device,
                  message: 'Vaso intelligente collegato ma offline.',
                ),
              );
            }
          },
          onError: (_) {
            emit(
              SmartPotFailure(
                message: 'Errore durante l’ascolto del vaso intelligente.',
                device: state.device,
              ),
            );
          },
        );
  }

  Future<void> linkDeviceToPlant({
    required String userId,
    required String deviceId,
    required String gardenPlantId,
    String? name,
    String? deviceCode,
  }) async {
    emit(SmartPotLoading(device: state.device));
    try {
      await _smartPotRepository.linkDeviceToPlant(
        userId: userId,
        deviceId: deviceId,
        gardenPlantId: gardenPlantId,
        name: name,
        deviceCode: deviceCode,
      );
      watchDevice(userId: userId, deviceId: deviceId);
    } on SmartPotRepositoryException catch (error) {
      emit(SmartPotFailure(message: error.message, device: state.device));
    } catch (_) {
      emit(
        SmartPotFailure(
          message: 'Errore imprevisto durante il collegamento del vaso.',
          device: state.device,
        ),
      );
    }
  }

  Future<void> unlinkDevice({
    required String userId,
    required String deviceId,
    required String gardenPlantId,
  }) async {
    emit(SmartPotLoading(device: state.device));
    try {
      await _smartPotRepository.unlinkDevice(
        userId: userId,
        deviceId: deviceId,
        gardenPlantId: gardenPlantId,
      );
      emit(
        const SmartPotDisconnected(
          message: 'Vaso intelligente scollegato.',
        ),
      );
    } on SmartPotRepositoryException catch (error) {
      emit(SmartPotFailure(message: error.message, device: state.device));
    } catch (_) {
      emit(
        SmartPotFailure(
          message: 'Errore imprevisto durante lo scollegamento del vaso.',
          device: state.device,
        ),
      );
    }
  }

  Future<void> updatePumpCalibration({
    required String userId,
    required String deviceId,
    required double pumpMlPerSecond,
  }) async {
    try {
      await _smartPotRepository.updatePumpCalibration(
        userId: userId,
        deviceId: deviceId,
        pumpMlPerSecond: pumpMlPerSecond,
      );
    } on SmartPotRepositoryException catch (error) {
      emit(SmartPotFailure(message: error.message, device: state.device));
    } catch (_) {
      emit(
        SmartPotFailure(
          message: 'Errore imprevisto durante la calibrazione.',
          device: state.device,
        ),
      );
    }
  }

  Future<void> requestManualIrrigation({
    required String userId,
    required String deviceId,
    required double waterMl,
    required double pumpRuntimeSeconds,
  }) async {
    try {
      await _smartPotRepository.requestManualIrrigation(
        userId: userId,
        deviceId: deviceId,
        waterMl: waterMl,
        pumpRuntimeSeconds: pumpRuntimeSeconds,
      );
    } on SmartPotRepositoryException catch (error) {
      emit(SmartPotFailure(message: error.message, device: state.device));
    } catch (_) {
      emit(
        SmartPotFailure(
          message: 'Errore imprevisto durante la richiesta di irrigazione.',
          device: state.device,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _deviceSubscription?.cancel();
    return super.close();
  }
}
