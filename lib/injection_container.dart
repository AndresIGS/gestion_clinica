import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- IMPORTACIONES DE AUTH ---
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'features/citas/data/datasources/citas_remote_data_source.dart';
import 'features/citas/domain/repositories/citas_repository.dart';
import 'features/citas/presentation/blocs/citas/citas_bloc.dart';
import 'features/notificaciones/presentation/blocs/notificaciones_bloc.dart';
import 'features/reportes/data/datasources/reportes_remote_data_source.dart';
import 'features/reportes/domain/repositories/reportes_repository.dart';
import 'features/reportes/presentation/blocs/reportes_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ==========================
  // BLoCs
  // ==========================
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => CitasBloc(citasRepository: sl())); // NUEVO
  sl.registerFactory(() => NotificacionesBloc(citasRepository: sl())); // NUEVO
  sl.registerFactory(() => ReportesBloc(repository: sl()));

  // ==========================
  // Repositorios
  // ==========================
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepository(remoteDataSource: sl()));
  sl.registerLazySingleton<CitasRepository>(
      () => CitasRepository(remoteDataSource: sl()));
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
  sl.registerLazySingleton<ReportesRemoteDataSource>(
      () => ReportesRemoteDataSourceImpl(supabaseClient: sl()));

  // Cliente Externo (Supabase) - Ya estaba
  sl.registerLazySingleton(() => Supabase.instance.client);
}
