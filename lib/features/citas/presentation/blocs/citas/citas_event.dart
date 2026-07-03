import 'package:equatable/equatable.dart';
import '../../../data/models/cita_model.dart';

abstract class CitasEvent extends Equatable {
  const CitasEvent();

  @override
  List<Object?> get props => [];
}

class CargarMedicosEvent extends CitasEvent {}

class SolicitarCitaEvent extends CitasEvent {
  final CitaModel cita;

  const SolicitarCitaEvent({required this.cita});

  @override
  List<Object?> get props => [cita];
}

class CargarCitasEvent extends CitasEvent {
  final String idUsuario;
  final int idRol;
  final int limit;
  final int offset;
  final bool esPrimeraCarga;
  final String? estado;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const CargarCitasEvent({
    required this.idUsuario,
    required this.idRol,
    this.limit = 20,
    this.offset = 0,
    this.esPrimeraCarga = true,
    this.estado,
    this.fechaInicio,
    this.fechaFin,
  });

  @override
  List<Object?> get props => [
        idUsuario,
        idRol,
        limit,
        offset,
        esPrimeraCarga,
        estado,
        fechaInicio,
        fechaFin,
      ];
}

class ActualizarEstadoCitaEvent extends CitasEvent {
  final int idCita;
  final String nuevoEstado;

  const ActualizarEstadoCitaEvent({required this.idCita, required this.nuevoEstado});

  @override
  List<Object?> get props => [idCita, nuevoEstado];
}
