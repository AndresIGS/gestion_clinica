import 'package:equatable/equatable.dart';
import '../../../data/models/cita_model.dart';

abstract class CitasEvent extends Equatable {
  const CitasEvent();

  @override
  List<Object> get props => [];
}

class CargarMedicosEvent extends CitasEvent {}

class SolicitarCitaEvent extends CitasEvent {
  final CitaModel cita;

  const SolicitarCitaEvent({required this.cita});

  @override
  List<Object> get props => [cita];
}

class CargarCitasEvent extends CitasEvent {
  final String idUsuario;
  final int idRol;

  const CargarCitasEvent({required this.idUsuario, required this.idRol});

  @override
  List<Object> get props => [idUsuario, idRol];
}

class ActualizarEstadoCitaEvent extends CitasEvent {
  final int idCita;
  final String nuevoEstado;

  const ActualizarEstadoCitaEvent({required this.idCita, required this.nuevoEstado});

  @override
  List<Object> get props => [idCita, nuevoEstado];
}
