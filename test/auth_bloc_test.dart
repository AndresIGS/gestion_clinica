import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistemav2/features/auth/data/models/usuario_model.dart';
import 'package:sistemav2/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:sistemav2/features/auth/presentation/blocs/auth/auth_event.dart';
import 'package:sistemav2/features/auth/presentation/blocs/auth/auth_state.dart';

import 'mocks.dart';

void main() {
  group('AuthBloc', () {
    late MockAuthRepository authRepository;
    late AuthBloc bloc;

    const usuario = UsuarioModel(
      idUsuario: 'uuid-123',
      idRol: 4,
      nombreCompleto: 'Paciente Prueba',
      correo: 'paciente@test.com',
    );

    setUp(() {
      authRepository = MockAuthRepository();
      bloc = AuthBloc(authRepository: authRepository);
    });

    tearDown(() => bloc.close());

    blocTest<AuthBloc, AuthState>(
      'emite [AuthLoading, AuthAuthenticated] al iniciar sesión correctamente',
      build: () {
        when(() => authRepository.iniciarSesion('paciente@test.com', '123456'))
            .thenAnswer((_) async => usuario);
        return bloc;
      },
      act: (bloc) => bloc.add(
        const LoginRequested(correo: 'paciente@test.com', password: '123456'),
      ),
      expect: () => [
        AuthLoading(),
        const AuthAuthenticated(usuario: usuario),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emite [AuthLoading, AuthError] cuando falla el login',
      build: () {
        when(() => authRepository.iniciarSesion(any(), any()))
            .thenThrow(Exception('Credenciales inválidas'));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const LoginRequested(correo: 'x@test.com', password: 'wrong'),
      ),
      expect: () => [
        AuthLoading(),
        isA<AuthError>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emite [AuthLoading, AuthAuthenticated] al registrar e iniciar sesión',
      build: () {
        when(
          () => authRepository.registrarUsuario(
            correo: any(named: 'correo'),
            password: any(named: 'password'),
            nombreCompleto: any(named: 'nombreCompleto'),
            idRol: any(named: 'idRol'),
            telefono: any(named: 'telefono'),
          ),
        ).thenAnswer((_) async {});
        when(() => authRepository.iniciarSesion(any(), any()))
            .thenAnswer((_) async => usuario);
        return bloc;
      },
      act: (bloc) => bloc.add(
        const RegisterRequested(
          correo: 'nuevo@test.com',
          password: '123456',
          nombreCompleto: 'Nuevo Usuario',
          idRol: 4,
          telefono: '5550000000',
        ),
      ),
      expect: () => [
        AuthLoading(),
        const AuthAuthenticated(usuario: usuario),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emite [AuthInitial] al cerrar sesión',
      build: () {
        when(() => authRepository.cerrarSesion()).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        AuthLoading(),
        AuthInitial(),
      ],
    );
  });
}
