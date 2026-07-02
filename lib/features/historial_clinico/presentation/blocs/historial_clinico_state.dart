import 'package:equatable/equatable.dart';
import '../../data/models/historial_clinico_model.dart';

abstract class HistorialClinicoState extends Equatable {
  const HistorialClinicoState();

  @override
  List<Object?> get props => [];
}

class HistorialClinicoInitial extends HistorialClinicoState {}

class HistorialClinicoLoading extends HistorialClinicoState {}

class HistorialClinicoLoaded extends HistorialClinicoState {
  final List<HistorialClinicoModel> historial;

  const HistorialClinicoLoaded({required this.historial});

  @override
  List<Object?> get props => [historial];
}

class HistorialClinicoPorCitaLoaded extends HistorialClinicoState {
  final HistorialClinicoModel? historial;

  const HistorialClinicoPorCitaLoaded({this.historial});

  @override
  List<Object?> get props => [historial];
}

class HistorialClinicoCreado extends HistorialClinicoState {}

class HistorialClinicoError extends HistorialClinicoState {
  final String mensaje;

  const HistorialClinicoError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}
