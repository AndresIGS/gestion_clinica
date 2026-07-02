import 'package:equatable/equatable.dart';

abstract class ReportesEvent extends Equatable {
  const ReportesEvent();

  @override
  List<Object?> get props => [];
}

class CargarEstadisticasEvent extends ReportesEvent {
  final String? idMedico;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const CargarEstadisticasEvent({
    this.idMedico,
    this.fechaInicio,
    this.fechaFin,
  });

  @override
  List<Object?> get props => [idMedico, fechaInicio, fechaFin];
}

class CargarMedicosReporteEvent extends ReportesEvent {}
