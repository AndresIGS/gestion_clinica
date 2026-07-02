import '../../data/datasources/citas_remote_data_source.dart';
import '../../data/models/cita_model.dart';

class CitasRepository {
  final CitasRemoteDataSource remoteDataSource;

  CitasRepository({required this.remoteDataSource});

  Future<void> agendarCita(CitaModel cita) async {
    await remoteDataSource.solicitarCita(cita);
  }

  Future<List<Map<String, dynamic>>> obtenerMedicos() async {
    return await remoteDataSource.obtenerMedicosDisponibles();
  }

  Future<List<CitaModel>> obtenerCitas(String idUsuario, int idRol) async {
    return await remoteDataSource.obtenerCitas(idUsuario, idRol);
  }

  Future<void> actualizarEstadoCita(int idCita, String nuevoEstado) async {
    await remoteDataSource.actualizarEstadoCita(idCita, nuevoEstado);
  }

  Stream<List<CitaModel>> escucharCambiosCitas() {
    return remoteDataSource.escucharCambiosCitas().map(
      (list) => list.map((json) => CitaModel.fromJson(json)).toList(),
    );
  }
}
