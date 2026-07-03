import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../data/models/cita_model.dart';
import '../../../domain/repositories/citas_repository.dart';
import 'citas_event.dart';
import 'citas_state.dart';

class CitasBloc extends Bloc<CitasEvent, CitasState> {
  final CitasRepository citasRepository;
  List<CitaModel> _citasActuales = [];

  CitasBloc({required this.citasRepository}) : super(CitasInitial()) {
    on<CargarMedicosEvent>((event, emit) async {
      emit(CitasLoading());
      try {
        final medicos = await citasRepository.obtenerMedicos();
        emit(MedicosCargados(medicos: medicos));
      } catch (e) {
        emit(CitasError(mensaje: ErrorHandler.map(e).message));
      }
    });

    on<SolicitarCitaEvent>((event, emit) async {
      emit(CitasLoading());
      try {
        await citasRepository.agendarCita(event.cita);
        emit(
          const CitaSolicitadaExito(
            mensaje: 'Su cita ha sido solicitada correctamente.',
          ),
        );
      } catch (e) {
        emit(CitasError(mensaje: ErrorHandler.map(e).message));
      }
    });

    on<CargarCitasEvent>((event, emit) async {
      if (event.esPrimeraCarga) {
        _citasActuales = [];
        emit(CitasLoading());
      } else {
        emit(CitasPaginando(citasActuales: _citasActuales));
      }

      try {
        final citas = await citasRepository.obtenerCitas(
          event.idUsuario,
          event.idRol,
          limit: event.limit,
          offset: event.offset,
          estado: event.estado,
          fechaInicio: event.fechaInicio,
          fechaFin: event.fechaFin,
        );

        if (event.esPrimeraCarga) {
          _citasActuales = citas;
        } else {
          _citasActuales = [..._citasActuales, ...citas];
        }

        emit(CitasListadas(
          citas: _citasActuales,
          hayMas: citas.length == event.limit,
        ));
      } catch (e) {
        emit(CitasError(mensaje: ErrorHandler.map(e).message));
      }
    });

    on<ActualizarEstadoCitaEvent>((event, emit) async {
      emit(CitasLoading());
      try {
        await citasRepository.actualizarEstadoCita(
          event.idCita,
          event.nuevoEstado,
        );
        emit(
          CitaEstadoActualizado(
            mensaje: 'El estado de la cita se actualizó a ${event.nuevoEstado}.',
          ),
        );
      } catch (e) {
        emit(CitasError(mensaje: ErrorHandler.map(e).message));
      }
    });
  }
}
