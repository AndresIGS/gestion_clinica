import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/reportes_repository.dart';
import 'reportes_event.dart';
import 'reportes_state.dart';

class ReportesBloc extends Bloc<ReportesEvent, ReportesState> {
  final ReportesRepository repository;

  ReportesBloc({required this.repository}) : super(ReportesInitial()) {
    on<CargarEstadisticasEvent>((event, emit) async {
      emit(ReportesLoading());
      try {
        final estadisticas = await repository.obtenerEstadisticasCitas();
        emit(EstadisticasCargadas(estadisticas: estadisticas));
      } catch (e) {
        emit(ReportesError(mensaje: e.toString()));
      }
    });
  }
}
