import 'package:equatable/equatable.dart';
import '../../../citas/data/models/cita_model.dart';

abstract class NotificacionesEvent extends Equatable {
  const NotificacionesEvent();

  @override
  List<Object> get props => [];
}

class IniciarEscuchaNotificaciones extends NotificacionesEvent {
  final String idUsuario;
  final int idRol;

  const IniciarEscuchaNotificaciones({required this.idUsuario, required this.idRol});

  @override
  List<Object> get props => [idUsuario, idRol];
}

class NotificacionRecibida extends NotificacionesEvent {
  final CitaModel cita;
  final String mensaje;

  const NotificacionRecibida({required this.cita, required this.mensaje});

  @override
  List<Object> get props => [cita, mensaje];
}
