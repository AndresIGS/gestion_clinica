import 'package:equatable/equatable.dart';

abstract class ReportesState extends Equatable {
  const ReportesState();

  @override
  List<Object?> get props => [];
}

class ReportesInitial extends ReportesState {}

class ReportesLoading extends ReportesState {}

class EstadisticasCargadas extends ReportesState {
  final Map<String, int> estadisticas;
  final String? idMedicoSeleccionado;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const EstadisticasCargadas({
    required this.estadisticas,
    this.idMedicoSeleccionado,
    this.fechaInicio,
    this.fechaFin,
  });

  @override
  List<Object?> get props => [
        estadisticas,
        idMedicoSeleccionado,
        fechaInicio,
        fechaFin,
      ];
}

class MedicosReporteCargados extends ReportesState {
  final List<Map<String, dynamic>> medicos;

  const MedicosReporteCargados({required this.medicos});

  @override
  List<Object?> get props => [medicos];
}

class ReportesError extends ReportesState {
  final String mensaje;

  const ReportesError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}
