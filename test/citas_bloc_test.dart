import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistemav2/features/citas/data/models/cita_model.dart';
import 'package:sistemav2/features/citas/presentation/blocs/citas/citas_bloc.dart';
import 'package:sistemav2/features/citas/presentation/blocs/citas/citas_event.dart';
import 'package:sistemav2/features/citas/presentation/blocs/citas/citas_state.dart';

import 'mocks.dart';

void main() {
  group('CitasBloc', () {
    late MockCitasRepository citasRepository;
    late CitasBloc bloc;

    final medico = {
      'id_medico': 'med-1',
      'usuario': {'nombre_completo': 'Dr. Ana'},
      'especialidad': {'nombre': 'Cardiología'},
    };

    final cita = CitaModel(
      idCita: 1,
      idPaciente: 'pac-1',
      idMedico: 'med-1',
      fechaHora: DateTime(2026, 7, 10, 10, 0),
      fechaHoraFin: DateTime(2026, 7, 10, 10, 30),
      estado: 'solicitado',
      motivo: 'Chequeo',
    );

    setUp(() {
      citasRepository = MockCitasRepository();
      bloc = CitasBloc(citasRepository: citasRepository);
    });

    tearDown(() => bloc.close());

    blocTest<CitasBloc, CitasState>(
      'emite [CitasLoading, MedicosCargados] al cargar médicos',
      build: () {
        when(() => citasRepository.obtenerMedicos())
            .thenAnswer((_) async => [medico]);
        return bloc;
      },
      act: (bloc) => bloc.add(CargarMedicosEvent()),
      expect: () => [
        CitasLoading(),
        MedicosCargados(medicos: [medico]),
      ],
    );

    blocTest<CitasBloc, CitasState>(
      'emite [CitasLoading, CitasListadas] al cargar citas',
      build: () {
        when(() => citasRepository.obtenerCitas('pac-1', 4))
            .thenAnswer((_) async => [cita]);
        return bloc;
      },
      act: (bloc) => bloc.add(
        const CargarCitasEvent(idUsuario: 'pac-1', idRol: 4),
      ),
      expect: () => [
        CitasLoading(),
        CitasListadas(citas: [cita]),
      ],
    );

    blocTest<CitasBloc, CitasState>(
      'emite [CitasLoading, CitaSolicitadaExito] al agendar cita',
      build: () {
        when(() => citasRepository.agendarCita(cita))
            .thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(SolicitarCitaEvent(cita: cita)),
      expect: () => [
        CitasLoading(),
        const CitaSolicitadaExito(
          mensaje: 'Su cita ha sido solicitada correctamente.',
        ),
      ],
    );

    blocTest<CitasBloc, CitasState>(
      'emite [CitasLoading, CitaEstadoActualizado] al actualizar estado',
      build: () {
        when(() => citasRepository.actualizarEstadoCita(1, 'aceptado'))
            .thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(
        const ActualizarEstadoCitaEvent(idCita: 1, nuevoEstado: 'aceptado'),
      ),
      expect: () => [
        CitasLoading(),
        const CitaEstadoActualizado(
          mensaje: 'El estado de la cita se actualizó a aceptado.',
        ),
      ],
    );

    blocTest<CitasBloc, CitasState>(
      'emite [CitasLoading, CitasError] cuando falla una operación',
      build: () {
        when(() => citasRepository.obtenerMedicos())
            .thenThrow(Exception('Error de red'));
        return bloc;
      },
      act: (bloc) => bloc.add(CargarMedicosEvent()),
      expect: () => [
        CitasLoading(),
        isA<CitasError>(),
      ],
    );
  });
}
