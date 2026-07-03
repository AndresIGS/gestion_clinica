import 'package:equatable/equatable.dart';
import '../../data/models/horario_medico_model.dart';

abstract class HorariosMedicoState extends Equatable {
  const HorariosMedicoState();

  @override
  List<Object?> get props => [];
}

class HorariosMedicoInitial extends HorariosMedicoState {}

class HorariosMedicoLoading extends HorariosMedicoState {}

class HorariosMedicoLoaded extends HorariosMedicoState {
  final List<HorarioMedicoModel> horarios;

  const HorariosMedicoLoaded({required this.horarios});

  @override
  List<Object?> get props => [horarios];
}

class HorarioMedicoOperacionExitosa extends HorariosMedicoState {}

class HorariosMedicoError extends HorariosMedicoState {
  final String mensaje;

  const HorariosMedicoError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}
