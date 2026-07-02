import 'package:equatable/equatable.dart';

/// Clase base para errores controlados de la aplicación.
///
/// Permite diferenciar errores de negocio, red, autenticación, etc.,
/// y mostrar mensajes amigables al usuario sin exponer detalles técnicos.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error de conexión a internet o timeout.
class NetworkFailure extends Failure {
  const NetworkFailure() : super('No se pudo conectar con el servidor. Verifica tu conexión a internet.');
}

/// Error cuando las credenciales son inválidas o la sesión expiró.
class AuthFailure extends Failure {
  const AuthFailure([String? detail])
      : super(detail ?? 'Correo o contraseña incorrectos.');
}

/// Error cuando el usuario no tiene permisos para realizar una acción.
class PermissionFailure extends Failure {
  const PermissionFailure()
      : super('No tienes permisos para realizar esta acción.');
}

/// Error cuando los datos enviados no son válidos.
class ValidationFailure extends Failure {
  const ValidationFailure([String? detail])
      : super(detail ?? 'Los datos ingresados no son válidos.');
}

/// Error cuando un recurso no existe (p. ej. usuario no encontrado).
class NotFoundFailure extends Failure {
  const NotFoundFailure([String? detail])
      : super(detail ?? 'El recurso solicitado no fue encontrado.');
}

/// Error genérico del servidor o de Supabase no clasificado.
class ServerFailure extends Failure {
  const ServerFailure([String? detail])
      : super(detail ?? 'Ocurrió un error en el servidor. Inténtalo de nuevo más tarde.');
}

/// Error desconocido. Se usa como último recurso.
class UnknownFailure extends Failure {
  const UnknownFailure() : super('Ocurrió un error inesperado. Inténtalo de nuevo.');
}
