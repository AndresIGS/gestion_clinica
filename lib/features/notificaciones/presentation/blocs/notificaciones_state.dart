import 'package:equatable/equatable.dart';

abstract class NotificacionesState extends Equatable {
  const NotificacionesState();

  @override
  List<Object> get props => [];
}

class NotificacionesInitial extends NotificacionesState {}

class NuevaNotificacionState extends NotificacionesState {
  final String mensaje;
  // uniqueId para forzar la actualización del estado incluso si el mensaje es igual
  final String uniqueId; 

  const NuevaNotificacionState({required this.mensaje, required this.uniqueId});

  @override
  List<Object> get props => [mensaje, uniqueId];
}
