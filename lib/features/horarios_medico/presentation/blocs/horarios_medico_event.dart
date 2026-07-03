import 'package:equatable/equatable.dart';
import '../../data/models/horario_medico_model.dart';

abstract class HorariosMedicoEvent extends Equatable {
  const HorariosMedicoEvent();

  @override
  List<Object?> get props => [];
}

class CargarHorariosMedicoEvent extends HorariosMedicoEvent {
  final String idMedico;

  const CargarHorariosMedicoEvent({required this.idMedico});

  @override
  List<Object?> get props => [idMedico];
}

class CrearHorarioMedicoEvent extends HorariosMedicoEvent {
  final HorarioMedicoModel horario;

  const CrearHorarioMedicoEvent({required this.horario});

  @override
  List<Object?> get props => [horario];
}

class ActualizarHorarioMedicoEvent extends HorariosMedicoEvent {
  final HorarioMedicoModel horario;

  const ActualizarHorarioMedicoEvent({required this.horario});

  @override
  List<Object?> get props => [horario];
}

class EliminarHorarioMedicoEvent extends HorariosMedicoEvent {
  final int idHorario;

  const EliminarHorarioMedicoEvent({required this.idHorario});

  @override
  List<Object?> get props => [idHorario];
}
