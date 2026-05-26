import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/smart_pot_repository.dart';
import 'irrigation_control_state.dart';

export 'irrigation_control_state.dart';

/// Cubit dedicato al comando manuale "Annaffia ora".
///
/// Non comanda direttamente Arduino: valida lo stato corrente del device e
/// crea un comando pending in `devices/{deviceId}/commands/{commandId}`.
class IrrigationControlCubit extends Cubit<IrrigationControlState> {
  IrrigationControlCubit({required SmartPotRepository smartPotRepository})
      : _smartPotRepository = smartPotRepository,
        super(const IrrigationControlInitial());

  final SmartPotRepository _smartPotRepository;

  Future<void> requestManualIrrigation({
    required String? deviceId,
    required String requestedBy,
  }) async {
    final safeDeviceId = deviceId?.trim() ?? '';
    final safeUserId = requestedBy.trim();

    if (safeDeviceId.isEmpty) {
      emit(const IrrigationControlFailure(
        message: 'Collega un vaso intelligente prima di annaffiare dall\'app.',
      ));
      return;
    }

    if (safeUserId.isEmpty) {
      emit(const IrrigationControlFailure(
        message: 'Utente non disponibile. Effettua nuovamente l\'accesso.',
      ));
      return;
    }

    emit(const IrrigationControlLoading());

    try {
      await _smartPotRepository.createManualIrrigationCommand(
        deviceId: safeDeviceId,
        requestedBy: safeUserId,
      );
      emit(const IrrigationControlSuccess(
        message: 'Comando di irrigazione inviato al vaso intelligente.',
      ));
    } on SmartPotRepositoryException catch (error) {
      emit(IrrigationControlFailure(message: error.message));
    } catch (_) {
      emit(const IrrigationControlFailure(
        message: 'Errore imprevisto durante l\'invio del comando.',
      ));
    }
  }

  void reset() => emit(const IrrigationControlInitial());
}
