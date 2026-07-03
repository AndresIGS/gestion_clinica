import 'package:supabase_flutter/supabase_flutter.dart';
import 'failures.dart';

/// Convierte una excepción genérica en un [Failure] concreto.
///
/// Uso típico en BLoCs:
/// ```dart
/// on<LoginRequested>((event, emit) async {
///   emit(AuthLoading());
///   try {
///     ...
///   } catch (e) {
///     emit(AuthError(mensaje: ErrorHandler.map(e).message));
///   }
/// });
/// ```
class ErrorHandler {
  ErrorHandler._();

  static Failure map(Object error) {
    if (error is Failure) return error;

    final message = error.toString().toLowerCase();

    // Errores de red / timeout
    if (message.contains('socket') ||
        message.contains('timeout') ||
        message.contains('failed host lookup') ||
        message.contains('network') ||
        message.contains('connection refused') ||
        message.contains('connection reset')) {
      return const NetworkFailure();
    }

    // Errores de autenticación de Supabase
    if (error is AuthException) {
      return _mapAuthException(error);
    }

    if (message.contains('invalid login credentials') ||
        message.contains('user not found') ||
        message.contains('email not confirmed') ||
        message.contains('incorrect password') ||
        message.contains('invalid credentials')) {
      return const AuthFailure('Correo o contraseña incorrectos.');
    }

    if (message.contains('session') && message.contains('expired')) {
      return const AuthFailure('Tu sesión expiró. Inicia sesión de nuevo.');
    }

    // Errores de PostgreSQL / Supabase
    if (error is PostgrestException) {
      return _mapPostgrestException(error);
    }

    if (message.contains('permission denied') ||
        message.contains('row-level security') ||
        message.contains('rls')) {
      return const PermissionFailure();
    }

    if (message.contains('not found') || message.contains('no rows')) {
      return const NotFoundFailure();
    }

    if (message.contains('duplicate') ||
        message.contains('already exists') ||
        message.contains('unique constraint')) {
      return ValidationFailure(_limpiarMensaje(error.toString()));
    }

    if (message.contains('rate limit') || message.contains('too many requests')) {
      return const ServerFailure('Demasiadas solicitudes. Espera un momento e inténtalo de nuevo.');
    }

    // Fallback
    return const UnknownFailure();
  }

  static Failure _mapAuthException(AuthException error) {
    final statusCode = error.statusCode;
    final msg = _limpiarMensaje(error.message).toLowerCase();

    if (statusCode == '400' ||
        msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials')) {
      return const AuthFailure('Correo o contraseña incorrectos.');
    }

    if (statusCode == '401' ||
        msg.contains('jwt') ||
        msg.contains('token') ||
        msg.contains('session')) {
      return const AuthFailure('Tu sesión expiró. Inicia sesión de nuevo.');
    }

    if (statusCode == '422' || msg.contains('email not confirmed')) {
      return const AuthFailure('Tu correo aún no ha sido confirmado.');
    }

    if (statusCode == '429') {
      return const ServerFailure('Demasiados intentos. Espera un momento.');
    }

    return AuthFailure(_limpiarMensaje(error.message));
  }

  static Failure _mapPostgrestException(PostgrestException error) {
    final code = error.code?.toLowerCase() ?? '';
    final message = _limpiarMensaje(error.message);

    return switch (code) {
      '23505' => ValidationFailure(message),
      '23503' => ValidationFailure(message),
      '42501' => const PermissionFailure(),
      'pgrst116' || 'pgrst301' => const NotFoundFailure(),
      _ => ServerFailure(message),
    };
  }

  /// Quita prefijos técnicos como "Exception: ..." para mostrar un mensaje
  /// más limpio al usuario.
  static String _limpiarMensaje(String mensaje) {
    return mensaje
        .replaceFirst(RegExp(r'^exception: ', caseSensitive: false), '')
        .replaceFirst(RegExp(r'^postgrestexception: ', caseSensitive: false), '')
        .trim();
  }
}
