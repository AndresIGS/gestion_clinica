import 'package:equatable/equatable.dart';
import '../../data/models/historial_cita_model.dart';

abstract class HistorialState extends Equatable {
  const HistorialState();

  @override
  List<Object?> get props => [];
}

class HistorialInitial extends HistorialState {}

class HistorialLoading extends HistorialState {}

class HistorialLoaded extends HistorialState {
  final List<HistorialCitaModel> historial;

  const HistorialLoaded({required this.historial});

  @override
  List<Object?> get props => [historial];
}

class HistorialError extends HistorialState {
  final String mensaje;

  const HistorialError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}
