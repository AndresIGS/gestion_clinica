import 'package:equatable/equatable.dart';
import '../../../data/models/cita_model.dart';

abstract class CitasState extends Equatable {
  const CitasState();

  @override
  List<Object?> get props => [];
}

class CitasInitial extends CitasState {}

class CitasLoading extends CitasState {}

class MedicosCargados extends CitasState {
  final List<Map<String, dynamic>> medicos;

  const MedicosCargados({required this.medicos});

  @override
  List<Object?> get props => [medicos];
}

class CitaSolicitadaExito extends CitasState {
  final String mensaje;

  const CitaSolicitadaExito({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}

class CitasError extends CitasState {
  final String mensaje;

  const CitasError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}

class CitasListadas extends CitasState {
  final List<CitaModel> citas;

  const CitasListadas({required this.citas});

  @override
  List<Object?> get props => [citas];
}

class CitaEstadoActualizado extends CitasState {
  final String mensaje;

  const CitaEstadoActualizado({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}
