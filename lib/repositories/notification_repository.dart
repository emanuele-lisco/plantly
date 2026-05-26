import '../features/plant/garden_plant.dart';

/// Repository predisposto per le notifiche di Plantly.
///
/// In questa fase non usa plugin nativi e non richiede configurazioni Android/iOS.
/// È volutamente uno scheletro sicuro: i metodi sono no-op controllati, pronti per
/// essere collegati in futuro a flutter_local_notifications, Firebase Messaging o
/// Cloud Functions.
class NotificationRepository {
  const NotificationRepository();

  Future<void> initialize() async {
    // TODO(notifications): inizializzare flutter_local_notifications o FCM.
    return;
  }

  Future<void> requestPermission() async {
    // TODO(notifications): richiedere permessi runtime su Android/iOS.
    return;
  }

  Future<void> scheduleWateringReminder(GardenPlant plant) async {
    if (!plant.notificationEnabled) return;
    if (plant.nextWateringAt == null) return;

    // TODO(notifications): programmare reminder irrigazione.
    // Dati già disponibili:
    // - plant.id
    // - plant.displayName
    // - plant.nextWateringAt
    // - plant.userId
    return;
  }

  Future<void> cancelWateringReminder(String plantId) async {
    if (plantId.trim().isEmpty) return;

    // TODO(notifications): cancellare reminder associato a plantId.
    return;
  }

  Future<void> rescheduleWateringReminder(GardenPlant plant) async {
    await cancelWateringReminder(plant.id);
    await scheduleWateringReminder(plant);
  }
}
