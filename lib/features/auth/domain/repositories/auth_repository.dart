import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/usuario_model.dart';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepository({required this.remoteDataSource});

  Future<UsuarioModel> iniciarSesion(String correo, String password) async {
    return await remoteDataSource.signIn(correo, password);
  }

  Future<void> registrarUsuario({
    required String correo,
    required String password,
    required String nombreCompleto,
    required int idRol,
  }) async {
    await remoteDataSource.signUp(
      correo: correo,
      password: password,
      nombreCompleto: nombreCompleto,
      idRol: idRol,
    );
  }

  Future<void> cerrarSesion() async {
    await remoteDataSource.signOut();
  }
}
