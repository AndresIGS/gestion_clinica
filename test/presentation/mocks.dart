import 'package:bloc_test/bloc_test.dart';
import 'package:sistemav2/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:sistemav2/features/auth/presentation/blocs/auth/auth_event.dart';
import 'package:sistemav2/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:sistemav2/features/citas/presentation/blocs/citas/citas_bloc.dart';
import 'package:sistemav2/features/citas/presentation/blocs/citas/citas_event.dart';
import 'package:sistemav2/features/citas/presentation/blocs/citas/citas_state.dart';
import 'package:sistemav2/features/notificaciones/presentation/blocs/notificaciones_bloc.dart';
import 'package:sistemav2/features/notificaciones/presentation/blocs/notificaciones_event.dart';
import 'package:sistemav2/features/notificaciones/presentation/blocs/notificaciones_state.dart';
import 'package:sistemav2/features/reportes/presentation/blocs/reportes_bloc.dart';
import 'package:sistemav2/features/reportes/presentation/blocs/reportes_event.dart';
import 'package:sistemav2/features/reportes/presentation/blocs/reportes_state.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockCitasBloc extends MockBloc<CitasEvent, CitasState> implements CitasBloc {}

class MockNotificacionesBloc
    extends MockBloc<NotificacionesEvent, NotificacionesState>
    implements NotificacionesBloc {}

class MockReportesBloc
    extends MockBloc<ReportesEvent, ReportesState>
    implements ReportesBloc {}
