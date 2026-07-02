import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  // CORRECCIÓN: Se agregó '?' para coincidir con la firma oficial de Equatable
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String correo;
  final String password;

  const LoginRequested({required this.correo, required this.password});

  @override
  // CORRECCIÓN: Se agregó '?' aquí también
  List<Object?> get props => [correo, password];
}

class LogoutRequested extends AuthEvent {}

class RegisterRequested extends AuthEvent {
  final String correo;
  final String password;
  final String nombreCompleto;
  final int idRol;
  final String telefono;
  final int? idEspecialidad;

  const RegisterRequested({
    required this.correo,
    required this.password,
    required this.nombreCompleto,
    required this.idRol,
    required this.telefono,
    this.idEspecialidad,
  });

  @override
  // Este ya estaba correcto, se queda igual
  List<Object?> get props => [
    correo,
    password,
    nombreCompleto,
    idRol,
    telefono,
    idEspecialidad,
  ];
}
