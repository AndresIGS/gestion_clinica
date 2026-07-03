import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistemav2/features/auth/data/models/usuario_model.dart';
import 'package:sistemav2/features/citas/data/models/cita_model.dart';
import 'package:sistemav2/features/citas/presentation/blocs/citas/citas_bloc.dart';
import 'package:sistemav2/features/citas/presentation/blocs/citas/citas_event.dart';
import 'package:sistemav2/features/citas/presentation/blocs/citas/citas_state.dart';
import 'package:sistemav2/features/citas/presentation/pages/listado_citas_screen.dart';

import 'mocks.dart';

class FakeCitasEvent extends Fake implements CitasEvent {}

void main() {
  late MockCitasBloc mockCitasBloc;

  final usuarioMedico = UsuarioModel(
    idUsuario: 'med-1',
    correo: 'medico@clinica.com',
    nombreCompleto: 'Dr. Ana',
    telefono: '555-0001',
    idRol: 3,
  );

  final cita = CitaModel(
    idCita: 1,
    idPaciente: 'pac-1',
    idMedico: 'med-1',
    fechaHora: DateTime(2026, 7, 10, 10, 0),
    fechaHoraFin: DateTime(2026, 7, 10, 10, 30),
    estado: 'solicitado',
    motivo: 'Chequeo general',
    nombrePaciente: 'Juan Pérez',
    nombreMedico: 'Dr. Ana',
  );

  setUpAll(() {
    registerFallbackValue(FakeCitasEvent());
  });

  setUp(() {
    mockCitasBloc = MockCitasBloc();
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: BlocProvider<CitasBloc>.value(
        value: mockCitasBloc,
        child: ListadoCitasScreen(usuario: usuarioMedico),
      ),
    );
  }

  void stubState(CitasState state) {
    when(() => mockCitasBloc.state).thenReturn(state);
    whenListen(
      mockCitasBloc,
      Stream.fromIterable([state]),
      initialState: state,
    );
  }

  testWidgets('muestra skeleton mientras carga', (tester) async {
    stubState(CitasLoading());

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();

    expect(find.byType(Card), findsWidgets);
  });

  testWidgets('muestra citas y dispara búsqueda', (tester) async {
    stubState(CitasListadas(citas: [cita], hayMas: false));

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.text('Paciente: Juan Pérez'), findsOneWidget);
    expect(find.text('Médico: Dr. Ana'), findsOneWidget);
    expect(find.text('Motivo: Chequeo general'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Juan');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    verify(() => mockCitasBloc.add(any(that: isA<CitasEvent>())))
        .called(greaterThan(0));
  });

  testWidgets('muestra empty state cuando no hay citas', (tester) async {
    stubState(CitasListadas(citas: const [], hayMas: false));

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.text('No hay citas'), findsOneWidget);
  });
}
