import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistemav2/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:sistemav2/features/auth/presentation/blocs/auth/auth_event.dart';
import 'package:sistemav2/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:sistemav2/features/auth/presentation/pages/login_screen.dart';

import 'mocks.dart';

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const LoginScreen(),
      ),
    );
  }

  testWidgets('muestra campos de correo y contraseña', (tester) async {
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.widgetWithText(TextFormField, 'Correo electrónico'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Contraseña'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Iniciar Sesión'), findsOneWidget);
  });

  testWidgets('emite LoginRequested al presionar el botón con datos válidos',
      (tester) async {
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Correo electrónico'),
      'usuario@clinica.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña'),
      '123456',
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar Sesión'));
    await tester.pump();

    verify(
      () => mockAuthBloc.add(
        const LoginRequested(
          correo: 'usuario@clinica.com',
          password: '123456',
        ),
      ),
    ).called(1);
  });

  testWidgets('muestra indicador de carga cuando el estado es AuthLoading',
      (tester) async {
    whenListen(
      mockAuthBloc,
      Stream.fromIterable([AuthInitial(), AuthLoading()]),
      initialState: AuthInitial(),
    );

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
