import 'package:equatable/equatable.dart';
import '../../../data/models/usuario_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UsuarioModel usuario;

  const AuthAuthenticated({required this.usuario});

  @override
  List<Object?> get props => [usuario];
}

class AuthError extends AuthState {
  final String mensaje;

  const AuthError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}
