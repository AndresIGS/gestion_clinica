import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- IMPORTACIONES DE AUTH ---
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'features/citas/data/datasources/citas_remote_data_source.dart';
import 'features/citas/domain/repositories/citas_repository.dart';
import 'features/citas/presentation/blocs/citas/citas_bloc.dart';
import 'features/historial/data/datasources/historial_remote_data_source.dart';
import 'features/historial/domain/repositories/historial_repository.dart';
import 'features/historial/presentation/blocs/historial_bloc.dart';
import 'features/historial_clinico/data/datasources/historial_clinico_remote_data_source.dart';
import 'features/historial_clinico/domain/repositories/historial_clinico_repository.dart';
import 'features/historial_clinico/presentation/blocs/historial_clinico_bloc.dart';
import 'features/horarios_medico/data/datasources/horarios_medico_remote_data_source.dart';
import 'features/horarios_medico/domain/repositories/horarios_medico_repository.dart';
import 'features/horarios_medico/presentation/blocs/horarios_medico_bloc.dart';
import 'features/notificaciones/presentation/blocs/notificaciones_bloc.dart';
import 'features/perfil/data/datasources/perfil_remote_data_source.dart';
import 'features/perfil/domain/repositories/perfil_repository.dart';
import 'features/perfil/presentation/blocs/perfil_bloc.dart';
import 'features/reportes/data/datasources/reportes_remote_data_source.dart';
import 'features/reportes/domain/repositories/reportes_repository.dart';
import 'features/reportes/presentation/blocs/reportes_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ==========================
  // BLoCs
  // ==========================
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => CitasBloc(citasRepository: sl()));
  sl.registerFactory(() => HistorialBloc(repository: sl()));
  sl.registerFactory(() => HistorialClinicoBloc(repository: sl()));
  sl.registerFactory(() => HorariosMedicoBloc(repository: sl()));
  sl.registerFactory(() => NotificacionesBloc(citasRepository: sl()));
  sl.registerFactory(() => PerfilBloc(repository: sl()));
  sl.registerFactory(() => ReportesBloc(repository: sl()));

  // ==========================
  // Repositorios
  // ==========================
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepository(remoteDataSource: sl()));
  sl.registerLazySingleton<CitasRepository>(
      () => CitasRepository(remoteDataSource: sl()));
  sl.registerLazySingleton<HistorialRepository>(
      () => HistorialRepository(remoteDataSource: sl()));
  sl.registerLazySingleton<HistorialClinicoRepository>(
      () => HistorialClinicoRepository(remoteDataSource: sl()));
  sl.registerLazySingleton<HorariosMedicoRepository>(
      () => HorariosMedicoRepository(remoteDataSource: sl()));
  sl.registerLazySingleton<PerfilRepository>(
      () => PerfilRepository(remoteDataSource: sl()));
  sl.registerLazySingleton<ReportesRepository>(
      () => ReportesRepository(remoteDataSource: sl()));

  // ==========================
  // Data Sources
  // ==========================
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );
  sl.registerLazySingleton<CitasRemoteDataSource>(
      () => CitasRemoteDataSourceImpl(supabaseClient: sl()));
  sl.registerLazySingleton<HistorialRemoteDataSource>(
      () => HistorialRemoteDataSourceImpl(supabaseClient: sl()));
  sl.registerLazySingleton<HistorialClinicoRemoteDataSource>(
      () => HistorialClinicoRemoteDataSourceImpl(supabaseClient: sl()));
  sl.registerLazySingleton<HorariosMedicoRemoteDataSource>(
      () => HorariosMedicoRemoteDataSourceImpl(supabaseClient: sl()));
  sl.registerLazySingleton<PerfilRemoteDataSource>(
      () => PerfilRemoteDataSourceImpl(supabaseClient: sl()));
  sl.registerLazySingleton<ReportesRemoteDataSource>(
      () => ReportesRemoteDataSourceImpl(supabaseClient: sl()));

  // Cliente Externo (Supabase) - Ya estaba
  sl.registerLazySingleton(() => Supabase.instance.client);
}
