import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/data/models/usuario_model.dart';

abstract class PerfilRemoteDataSource {
  Future<UsuarioModel> obtenerPerfil();
  Future<UsuarioModel> actualizarPerfil({
    required String nombreCompleto,
    required String telefono,
  });
}

class PerfilRemoteDataSourceImpl implements PerfilRemoteDataSource {
  final SupabaseClient supabaseClient;

  PerfilRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UsuarioModel> obtenerPerfil() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw Exception('No hay sesión activa');
    }

    final response = await supabaseClient
        .from('usuario')
        .select()
        .eq('id_usuario', user.id)
        .single();

    return UsuarioModel.fromJson(response);
  }

  @override
  Future<UsuarioModel> actualizarPerfil({
    required String nombreCompleto,
    required String telefono,
  }) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw Exception('No hay sesión activa');
    }

    final response = await supabaseClient
        .from('usuario')
        .update({
          'nombre_completo': nombreCompleto,
          'telefono': telefono,
        })
        .eq('id_usuario', user.id)
        .select()
        .single();

    return UsuarioModel.fromJson(response);
  }
}
