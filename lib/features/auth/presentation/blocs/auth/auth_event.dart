import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String correo;
  final String password;

  const LoginRequested({required this.correo, required this.password});

  @override
  List<Object> get props => [correo, password];
}

class LogoutRequested extends AuthEvent {}

class RegisterRequested extends AuthEvent {
  final String correo;
  final String password;
  final String nombreCompleto;
  final int idRol;

  const RegisterRequested({
    required this.correo,
    required this.password,
    required this.nombreCompleto,
    required this.idRol,
  });

  @override
  List<Object> get props => [correo, password, nombreCompleto, idRol];
}
