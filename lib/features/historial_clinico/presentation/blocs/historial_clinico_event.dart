import 'package:equatable/equatable.dart';
import '../../data/models/historial_clinico_model.dart';

abstract class HistorialClinicoEvent extends Equatable {
  const HistorialClinicoEvent();

  @override
  List<Object?> get props => [];
}

class CargarHistorialClinicoEvent extends HistorialClinicoEvent {
  final String idPaciente;

  const CargarHistorialClinicoEvent({required this.idPaciente});

  @override
  List<Object?> get props => [idPaciente];
}

class CargarHistorialPorCitaEvent extends HistorialClinicoEvent {
  final int idCita;

  const CargarHistorialPorCitaEvent({required this.idCita});

  @override
  List<Object?> get props => [idCita];
}

class CrearHistorialClinicoEvent extends HistorialClinicoEvent {
  final HistorialClinicoModel historial;

  const CrearHistorialClinicoEvent({required this.historial});

  @override
  List<Object?> get props => [historial];
}
