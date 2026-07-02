import 'package:equatable/equatable.dart';
import '../../../auth/data/models/usuario_model.dart';

abstract class PerfilState extends Equatable {
  const PerfilState();

  @override
  List<Object?> get props => [];
}

class PerfilInitial extends PerfilState {}

class PerfilLoading extends PerfilState {}

class PerfilLoaded extends PerfilState {
  final UsuarioModel usuario;

  const PerfilLoaded({required this.usuario});

  @override
  List<Object?> get props => [usuario];
}

class PerfilActualizado extends PerfilState {
  final UsuarioModel usuario;

  const PerfilActualizado({required this.usuario});

  @override
  List<Object?> get props => [usuario];
}

class PerfilError extends PerfilState {
  final String mensaje;

  const PerfilError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}
