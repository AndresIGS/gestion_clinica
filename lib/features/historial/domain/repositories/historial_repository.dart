import '../../data/datasources/historial_remote_data_source.dart';
import '../../data/models/historial_cita_model.dart';

class HistorialRepository {
  final HistorialRemoteDataSource remoteDataSource;

  HistorialRepository({required this.remoteDataSource});

  Future<List<HistorialCitaModel>> obtenerHistorial() async {
    return await remoteDataSource.obtenerHistorial();
  }
}
