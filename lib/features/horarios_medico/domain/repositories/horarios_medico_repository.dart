import '../../data/datasources/horarios_medico_remote_data_source.dart';
import '../../data/models/horario_medico_model.dart';

class HorariosMedicoRepository {
  final HorariosMedicoRemoteDataSource remoteDataSource;

  HorariosMedicoRepository({required this.remoteDataSource});

  Future<List<HorarioMedicoModel>> obtenerHorarios(String idMedico) async {
    return await remoteDataSource.obtenerHorarios(idMedico);
  }

  Future<void> crearHorario(HorarioMedicoModel horario) async {
    return await remoteDataSource.crearHorario(horario);
  }

  Future<void> actualizarHorario(HorarioMedicoModel horario) async {
    return await remoteDataSource.actualizarHorario(horario);
  }

  Future<void> eliminarHorario(int idHorario) async {
    return await remoteDataSource.eliminarHorario(idHorario);
  }
}
