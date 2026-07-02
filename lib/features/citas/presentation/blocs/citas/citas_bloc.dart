import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/citas_repository.dart';
import 'citas_event.dart';
import 'citas_state.dart';

class CitasBloc extends Bloc<CitasEvent, CitasState> {
  final CitasRepository citasRepository;

  CitasBloc({required this.citasRepository}) : super(CitasInitial()) {
    // Escuchar el evento para cargar los médicos en el formulario
    on<CargarMedicosEvent>((event, emit) async {
      emit(CitasLoading());
      try {
        final medicos = await citasRepository.obtenerMedicos();
        emit(MedicosCargados(medicos: medicos));
      } catch (e) {
        emit(CitasError(mensaje: e.toString()));
      }
    });

    // Escuchar el evento cuando el paciente hace clic en "Guardar Cita"
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
        emit(CitasError(mensaje: e.toString()));
      }
    });

    on<CargarCitasEvent>((event, emit) async {
      emit(CitasLoading());
      try {
        final citas = await citasRepository.obtenerCitas(event.idUsuario, event.idRol);
        emit(CitasListadas(citas: citas));
      } catch (e) {
        emit(CitasError(mensaje: e.toString()));
      }
    });

    on<ActualizarEstadoCitaEvent>((event, emit) async {
      emit(CitasLoading());
      try {
        await citasRepository.actualizarEstadoCita(event.idCita, event.nuevoEstado);
        emit(
          CitaEstadoActualizado(
            mensaje: 'El estado de la cita se actualizó a ${event.nuevoEstado}.',
          ),
        );
      } catch (e) {
        emit(CitasError(mensaje: e.toString()));
      }
    });
  }
}
