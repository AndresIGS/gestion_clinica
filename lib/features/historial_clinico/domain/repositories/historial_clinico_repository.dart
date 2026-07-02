import '../../data/datasources/historial_clinico_remote_data_source.dart';
import '../../data/models/historial_clinico_model.dart';

class HistorialClinicoRepository {
  final HistorialClinicoRemoteDataSource remoteDataSource;

  HistorialClinicoRepository({required this.remoteDataSource});

  Future<List<HistorialClinicoModel>> obtenerHistorialPorPaciente(
    String idPaciente,
  ) async {
    return await remoteDataSource.obtenerHistorialPorPaciente(idPaciente);
  }

  Future<HistorialClinicoModel?> obtenerPorCita(int idCita) async {
    return await remoteDataSource.obtenerPorCita(idCita);
  }

  Future<void> crearHistorial(HistorialClinicoModel historial) async {
    return await remoteDataSource.crearHistorial(historial);
  }
}
