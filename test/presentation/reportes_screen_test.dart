import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistemav2/features/reportes/presentation/blocs/reportes_bloc.dart';
import 'package:sistemav2/features/reportes/presentation/blocs/reportes_event.dart';
import 'package:sistemav2/features/reportes/presentation/blocs/reportes_state.dart';
import 'package:sistemav2/features/reportes/presentation/pages/reportes_screen.dart';

import 'mocks.dart';

void main() {
  late MockReportesBloc mockReportesBloc;

  setUp(() {
    mockReportesBloc = MockReportesBloc();
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: BlocProvider<ReportesBloc>.value(
        value: mockReportesBloc,
        child: const ReportesScreen(),
      ),
    );
  }

  void stubState(ReportesState state) {
    when(() => mockReportesBloc.state).thenReturn(state);
    whenListen(
      mockReportesBloc,
      Stream.fromIterable([state]),
      initialState: state,
    );
  }

  testWidgets('muestra filtros y resumen de estadísticas', (tester) async {
    stubState(
      const EstadisticasCargadas(
        estadisticas: {
          'solicitado': 2,
          'aceptado': 5,
          'realizado': 8,
          'cancelado': 1,
        },
      ),
    );

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.text('Reportes y Estadísticas'), findsOneWidget);
    expect(find.text('Filtros'), findsOneWidget);
    expect(find.text('Total de citas'), findsOneWidget);
    expect(find.text('16'), findsOneWidget);
    expect(find.text('Detalle'), findsOneWidget);
  });

  testWidgets('dispara carga inicial de médicos y estadísticas',
      (tester) async {
    stubState(ReportesInitial());

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();
    await tester.pumpAndSettle();

    verify(() => mockReportesBloc.add(CargarMedicosReporteEvent())).called(1);
    verify(
      () => mockReportesBloc.add(
        const CargarEstadisticasEvent(),
      ),
    ).called(1);
  });
}
