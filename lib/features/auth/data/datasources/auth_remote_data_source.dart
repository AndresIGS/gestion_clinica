import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario_model.dart';

// Definimos el contrato (interfaz)
abstract class AuthRemoteDataSource {
  Future<UsuarioModel> signIn(String correo, String password);
  Future<void> signUp({
    required String correo,
    required String password,
    required String nombreCompleto,
    required int idRol,
    required String telefono,
    int? idEspecialidad,
    // --- NUEVOS CAMPOS AÑADIDOS AL CONTRATO ---
    String? matriculaMedica,
    String? fechaNacimiento,
  });
  Future<void> signOut();
}

// Implementación real usando el cliente de Supabase
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UsuarioModel> signIn(String correo, String password) async {
    try {
      // 1. Iniciar sesión en el sistema interno de Supabase Auth
      final response = await supabaseClient.auth.signInWithPassword(
        email: correo,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Error al autenticar el usuario.');
      }

      // 2. Traer los datos del usuario desde nuestra tabla pública 'usuario'
      // Esto funciona gracias a que los IDs coinciden y tenemos permisos
      final userData = await supabaseClient
          .from('usuario')
          .select()
          .eq('id_usuario', response.user!.id)
          .single();

      // Convertimos el JSON a nuestro Modelo usando el Factory
      return UsuarioModel.fromJson(userData);
    } catch (e) {
      throw Exception('Fallo el inicio de sesión: $e');
    }
  }

  @override
  Future<void> signUp({
    required String correo,
    required String password,
    required String nombreCompleto,
    required int idRol,
    required String telefono,
    int? idEspecialidad,
    // --- NUEVOS CAMPOS RECIBIDOS EN LA IMPLEMENTACIÓN ---
    String? matriculaMedica,
    String? fechaNacimiento,
  }) async {
    try {
      // Enviar credenciales Y metadatos.
      debugPrint(
        "Datos enviados: nombre_completo: $nombreCompleto, id_rol: $idRol, telefono: $telefono",
      );
      // El Trigger en SQL capturará la 'data' y llenará la tabla pública automáticamente.
      await supabaseClient.auth.signUp(
        email: correo,
        password: password,
        data: {
          'nombre_completo': nombreCompleto,
          'id_rol': idRol,
          'telefono': telefono,
          'id_especialidad': idEspecialidad,
          // --- ENVÍO DE DATOS A SUPABASE ---
          // En auth_remote_data_source.dart
          'matricula_medica': matriculaMedica,
          'fecha_nacimiento': fechaNacimiento,
        },
      );
    } catch (e) {
      throw Exception('Fallo el registro: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await supabaseClient.auth.signOut();
  }
}
