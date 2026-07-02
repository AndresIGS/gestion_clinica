import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/error_handler.dart';
import '../../domain/repositories/perfil_repository.dart';
import 'perfil_event.dart';
import 'perfil_state.dart';

class PerfilBloc extends Bloc<PerfilEvent, PerfilState> {
  final PerfilRepository repository;

  PerfilBloc({required this.repository}) : super(PerfilInitial()) {
    on<CargarPerfilEvent>((event, emit) async {
      emit(PerfilLoading());
      try {
        final usuario = await repository.obtenerPerfil();
        emit(PerfilLoaded(usuario: usuario));
      } catch (e) {
        emit(PerfilError(mensaje: ErrorHandler.map(e).message));
      }
    });

    on<ActualizarPerfilEvent>((event, emit) async {
      emit(PerfilLoading());
      try {
        final usuario = await repository.actualizarPerfil(
          nombreCompleto: event.nombreCompleto,
          telefono: event.telefono,
        );
        emit(PerfilActualizado(usuario: usuario));
      } catch (e) {
        emit(PerfilError(mensaje: ErrorHandler.map(e).message));
      }
    });
  }
}
