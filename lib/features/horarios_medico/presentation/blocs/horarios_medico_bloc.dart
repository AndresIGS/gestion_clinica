import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/error_handler.dart';
import '../../domain/repositories/horarios_medico_repository.dart';
import 'horarios_medico_event.dart';
import 'horarios_medico_state.dart';

class HorariosMedicoBloc
    extends Bloc<HorariosMedicoEvent, HorariosMedicoState> {
  final HorariosMedicoRepository repository;

  HorariosMedicoBloc({required this.repository})
      : super(HorariosMedicoInitial()) {
    on<CargarHorariosMedicoEvent>((event, emit) async {
      emit(HorariosMedicoLoading());
      try {
        final horarios = await repository.obtenerHorarios(event.idMedico);
        emit(HorariosMedicoLoaded(horarios: horarios));
      } catch (e) {
        emit(HorariosMedicoError(mensaje: ErrorHandler.map(e).message));
      }
    });

    on<CrearHorarioMedicoEvent>((event, emit) async {
      emit(HorariosMedicoLoading());
      try {
        await repository.crearHorario(event.horario);
        emit(HorarioMedicoOperacionExitosa());
      } catch (e) {
        emit(HorariosMedicoError(mensaje: ErrorHandler.map(e).message));
      }
    });

    on<ActualizarHorarioMedicoEvent>((event, emit) async {
      emit(HorariosMedicoLoading());
      try {
        await repository.actualizarHorario(event.horario);
        emit(HorarioMedicoOperacionExitosa());
      } catch (e) {
        emit(HorariosMedicoError(mensaje: ErrorHandler.map(e).message));
      }
    });

    on<EliminarHorarioMedicoEvent>((event, emit) async {
      emit(HorariosMedicoLoading());
      try {
        await repository.eliminarHorario(event.idHorario);
        emit(HorarioMedicoOperacionExitosa());
      } catch (e) {
        emit(HorariosMedicoError(mensaje: ErrorHandler.map(e).message));
      }
    });
  }
}
