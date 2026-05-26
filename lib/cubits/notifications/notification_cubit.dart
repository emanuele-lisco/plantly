import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/plant/garden_plant.dart';
import '../../repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({required NotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository,
        super(const NotificationInitial());

  final NotificationRepository _notificationRepository;

  Future<void> initialize() async {
    emit(const NotificationLoading());

    try {
      await _notificationRepository.initialize();
      emit(const NotificationInitial());
    } catch (_) {
      emit(const NotificationFailure('Errore durante l’inizializzazione delle notifiche.'));
    }
  }

  Future<void> requestPermission() async {
    emit(const NotificationLoading());

    try {
      await _notificationRepository.requestPermission();
      // In questa fase il repository è uno scheletro no-op.
      // Quando verrà integrato un plugin reale, qui andrà emesso
      // NotificationPermissionGranted o NotificationPermissionDenied in base
      // all'esito effettivo della richiesta permesso.
      emit(const NotificationPermissionGranted());
    } catch (_) {
      emit(const NotificationPermissionDenied());
    }
  }

  Future<void> scheduleWateringReminder(GardenPlant plant) async {
    emit(const NotificationLoading());

    try {
      await _notificationRepository.scheduleWateringReminder(plant);
      emit(NotificationScheduled(plantId: plant.id));
    } catch (_) {
      emit(const NotificationFailure('Errore durante la programmazione del reminder.'));
    }
  }

  Future<void> cancelWateringReminder(String plantId) async {
    emit(const NotificationLoading());

    try {
      await _notificationRepository.cancelWateringReminder(plantId);
      emit(const NotificationInitial());
    } catch (_) {
      emit(const NotificationFailure('Errore durante la cancellazione del reminder.'));
    }
  }

  Future<void> rescheduleWateringReminder(GardenPlant plant) async {
    emit(const NotificationLoading());

    try {
      await _notificationRepository.rescheduleWateringReminder(plant);
      emit(NotificationScheduled(plantId: plant.id));
    } catch (_) {
      emit(const NotificationFailure('Errore durante l’aggiornamento del reminder.'));
    }
  }
}
