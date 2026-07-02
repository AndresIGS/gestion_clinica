import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/error_handler.dart';
import '../../domain/repositories/historial_clinico_repository.dart';
import 'historial_clinico_event.dart';
import 'historial_clinico_state.dart';

class HistorialClinicoBloc
    extends Bloc<HistorialClinicoEvent, HistorialClinicoState> {
  final HistorialClinicoRepository repository;

  HistorialClinicoBloc({required this.repository})
      : super(HistorialClinicoInitial()) {
    on<CargarHistorialClinicoEvent>((event, emit) async {
      emit(HistorialClinicoLoading());
      try {
        final historial =
            await repository.obtenerHistorialPorPaciente(event.idPaciente);
        emit(HistorialClinicoLoaded(historial: historial));
      } catch (e) {
        emit(HistorialClinicoError(mensaje: ErrorHandler.map(e).message));
      }
    });

    on<CargarHistorialPorCitaEvent>((event, emit) async {
      emit(HistorialClinicoLoading());
      try {
        final historial = await repository.obtenerPorCita(event.idCita);
        emit(HistorialClinicoPorCitaLoaded(historial: historial));
      } catch (e) {
        emit(HistorialClinicoError(mensaje: ErrorHandler.map(e).message));
      }
    });

    on<CrearHistorialClinicoEvent>((event, emit) async {
      emit(HistorialClinicoLoading());
      try {
        await repository.crearHistorial(event.historial);
        emit(HistorialClinicoCreado());
      } catch (e) {
        emit(HistorialClinicoError(mensaje: ErrorHandler.map(e).message));
      }
    });
  }
}
