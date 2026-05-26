import 'package:equatable/equatable.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

final class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

final class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

final class NotificationPermissionGranted extends NotificationState {
  const NotificationPermissionGranted();
}

final class NotificationPermissionDenied extends NotificationState {
  const NotificationPermissionDenied({this.message = 'Permesso notifiche negato.'});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class NotificationScheduled extends NotificationState {
  const NotificationScheduled({required this.plantId});

  final String plantId;

  @override
  List<Object?> get props => [plantId];
}

final class NotificationFailure extends NotificationState {
  const NotificationFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
