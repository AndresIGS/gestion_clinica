import 'package:equatable/equatable.dart';

abstract class ReportesState extends Equatable {
  const ReportesState();

  @override
  List<Object> get props => [];
}

class ReportesInitial extends ReportesState {}

class ReportesLoading extends ReportesState {}

class EstadisticasCargadas extends ReportesState {
  final Map<String, int> estadisticas;

  const EstadisticasCargadas({required this.estadisticas});

  @override
  List<Object> get props => [estadisticas];
}

class ReportesError extends ReportesState {
  final String mensaje;

  const ReportesError({required this.mensaje});

  @override
  List<Object> get props => [mensaje];
}
