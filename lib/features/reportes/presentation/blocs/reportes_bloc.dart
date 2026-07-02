import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../domain/repositories/reportes_repository.dart';
import 'reportes_event.dart';
import 'reportes_state.dart';

class ReportesBloc extends Bloc<ReportesEvent, ReportesState> {
  final ReportesRepository repository;

  ReportesBloc({required this.repository}) : super(ReportesInitial()) {
    on<CargarEstadisticasEvent>((event, emit) async {
      emit(ReportesLoading());
      try {
        final estadisticas = await repository.obtenerEstadisticasCitas(
          idMedico: event.idMedico,
          fechaInicio: event.fechaInicio,
          fechaFin: event.fechaFin,
        );
        emit(EstadisticasCargadas(
          estadisticas: estadisticas,
          idMedicoSeleccionado: event.idMedico,
          fechaInicio: event.fechaInicio,
          fechaFin: event.fechaFin,
        ));
      } catch (e) {
        emit(ReportesError(mensaje: ErrorHandler.map(e).message));
      }
    });

    on<CargarMedicosReporteEvent>((event, emit) async {
      emit(ReportesLoading());
      try {
        final medicos = await repository.obtenerMedicos();
        emit(MedicosReporteCargados(medicos: medicos));
      } catch (e) {
        emit(ReportesError(mensaje: ErrorHandler.map(e).message));
      }
    });
  }
}
