import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    // Escuchar el evento de Login
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading()); // Muestra el círculo de carga en la UI
      try {
        final usuario = await authRepository.iniciarSesion(
          event.correo,
          event.password,
        );
        emit(AuthAuthenticated(usuario: usuario)); // Redirige según el rol
      } catch (e) {
        emit(AuthError(mensaje: ErrorHandler.map(e).message)); // Muestra el error
      }
    });

    // Escuchar el evento de Registro
    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        // 1. Registramos al usuario en Supabase (esto dispara tu Trigger en SQL)
        await authRepository.registrarUsuario(
          correo: event.correo,
          password: event.password,
          nombreCompleto: event.nombreCompleto,
          idRol: event.idRol,
          telefono: event.telefono,
          idEspecialidad: event.idEspecialidad,
          // --- NUEVOS CAMPOS AÑADIDOS AQUÍ ---
          matriculaMedica: event.matriculaMedica,
          fechaNacimiento: event.fechaNacimiento,
        );

        // 2. Si el registro fue exitoso, iniciamos sesión automáticamente
        final usuario = await authRepository.iniciarSesion(
          event.correo,
          event.password,
        );
        emit(AuthAuthenticated(usuario: usuario));
      } catch (e) {
        emit(AuthError(mensaje: ErrorHandler.map(e).message));
      }
    });

    // Escuchar el evento de Cerrar Sesión
    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.cerrarSesion();
        emit(AuthInitial()); // Vuelve a la pantalla de login
      } catch (e) {
        emit(AuthError(mensaje: ErrorHandler.map(e).message));
      }
    });
  }
}
