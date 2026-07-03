import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistemav2/features/auth/data/models/usuario_model.dart';
import 'package:sistemav2/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:sistemav2/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:sistemav2/features/auth/presentation/pages/dashboard_screen.dart';
import 'package:sistemav2/features/citas/presentation/blocs/citas/citas_bloc.dart';
import 'package:sistemav2/features/citas/presentation/blocs/citas/citas_state.dart';
import 'package:sistemav2/features/notificaciones/presentation/blocs/notificaciones_bloc.dart';
import 'package:sistemav2/features/notificaciones/presentation/blocs/notificaciones_state.dart';

import 'mocks.dart';

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockCitasBloc mockCitasBloc;
  late MockNotificacionesBloc mockNotificacionesBloc;

  final usuarioPaciente = UsuarioModel(
    idUsuario: 'paciente-1',
    correo: 'paciente@clinica.com',
    nombreCompleto: 'Juan Pérez',
    telefono: '555-0000',
    idRol: 4,
  );

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockCitasBloc = MockCitasBloc();
    mockNotificacionesBloc = MockNotificacionesBloc();
  });

  Widget buildTestableWidget(UsuarioModel usuario) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
          BlocProvider<CitasBloc>.value(value: mockCitasBloc),
          BlocProvider<NotificacionesBloc>.value(value: mockNotificacionesBloc),
        ],
        child: DashboardScreen(usuario: usuario),
      ),
    );
  }

  testWidgets('muestra saludo y accesos rápidos para paciente', (tester) async {
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    when(() => mockCitasBloc.state).thenReturn(CitasListadas(citas: const [], hayMas: false));
    when(() => mockNotificacionesBloc.state).thenReturn(NotificacionesInitial());

    await tester.pumpWidget(buildTestableWidget(usuarioPaciente));
    await tester.pumpAndSettle();

    expect(find.text('¡Hola, Juan Pérez!'), findsOneWidget);
    expect(find.text('Paciente'), findsOneWidget);
    expect(find.text('Mis Citas'), findsOneWidget);
    expect(find.text('Agendar Cita'), findsOneWidget);
    expect(find.text('Mi Historial Clínico'), findsOneWidget);
  });

  testWidgets('muestra sección de próximas citas vacías', (tester) async {
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    when(() => mockCitasBloc.state).thenReturn(CitasListadas(citas: const [], hayMas: false));
    when(() => mockNotificacionesBloc.state).thenReturn(NotificacionesInitial());

    await tester.pumpWidget(buildTestableWidget(usuarioPaciente));
    await tester.pumpAndSettle();

    expect(find.text('Próximas citas'), findsOneWidget);
    expect(find.text('Sin citas próximas'), findsOneWidget);
  });
}
