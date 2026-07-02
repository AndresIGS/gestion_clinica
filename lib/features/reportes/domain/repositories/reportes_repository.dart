import '../../data/datasources/reportes_remote_data_source.dart';

class ReportesRepository {
  final ReportesRemoteDataSource remoteDataSource;

  ReportesRepository({required this.remoteDataSource});

  Future<Map<String, int>> obtenerEstadisticasCitas() async {
    return await remoteDataSource.obtenerEstadisticasCitas();
  }
}
