import '../../data/datasources/perfil_remote_data_source.dart';
import '../../../auth/data/models/usuario_model.dart';

class PerfilRepository {
  final PerfilRemoteDataSource remoteDataSource;

  PerfilRepository({required this.remoteDataSource});

  Future<UsuarioModel> obtenerPerfil() async {
    return await remoteDataSource.obtenerPerfil();
  }

  Future<UsuarioModel> actualizarPerfil({
    required String nombreCompleto,
    required String telefono,
  }) async {
    return await remoteDataSource.actualizarPerfil(
      nombreCompleto: nombreCompleto,
      telefono: telefono,
    );
  }
}
