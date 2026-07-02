import '../../data/datasources/reportes_remote_data_source.dart';

class ReportesRepository {
  final ReportesRemoteDataSource remoteDataSource;

  ReportesRepository({required this.remoteDataSource});

  Future<Map<String, int>> obtenerEstadisticasCitas({
    String? idMedico,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    return await remoteDataSource.obtenerEstadisticasCitas(
      idMedico: idMedico,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
    );
  }

  Future<List<Map<String, dynamic>>> obtenerMedicos() async {
    return await remoteDataSource.obtenerMedicos();
  }
}
