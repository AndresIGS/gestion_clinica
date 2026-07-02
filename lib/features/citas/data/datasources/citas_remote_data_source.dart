import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cita_model.dart';

abstract class CitasRemoteDataSource {
  Future<void> solicitarCita(CitaModel cita);
  Future<List<Map<String, dynamic>>> obtenerMedicosDisponibles();
  Future<List<CitaModel>> obtenerCitas(String idUsuario, int idRol);
  Future<void> actualizarEstadoCita(int idCita, String nuevoEstado);
  Stream<List<Map<String, dynamic>>> escucharCambiosCitas();
}

class CitasRemoteDataSourceImpl implements CitasRemoteDataSource {
  final SupabaseClient supabaseClient;

  CitasRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> solicitarCita(CitaModel cita) async {
    try {
      // Validamos que el paciente que solicita es el mismo que está autenticado (RLS Policy)
      final pacienteActual = supabaseClient.auth.currentUser?.id;
      if (pacienteActual != cita.idPaciente) {
        throw Exception(
          'Permiso denegado: El ID del paciente no coincide con la sesión actual.',
        );
      }

      // Insertamos la cita. El Trigger de SQL creará el Historial automáticamente
      await supabaseClient.from('cita').insert(cita.toJson());
    } catch (e) {
      throw Exception('Error al agendar la cita: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> obtenerMedicosDisponibles() async {
    try {
      // Consulta relacional: Obtenemos el id del médico y su nombre desde la tabla usuario
      final response = await supabaseClient
          .from('medico')
          .select('id_medico, usuario(nombre_completo)');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error al cargar la lista de médicos: $e');
    }
  }

  @override
  Future<List<CitaModel>> obtenerCitas(String idUsuario, int idRol) async {
    try {
      var query = supabaseClient.from('cita').select();
      
      // Aplicar filtros según el rol localmente si fuera necesario, 
      // aunque el RLS de Supabase ya filtra automáticamente a nivel de DB.
      // Por si acaso, lo reforzamos aquí para la vista.
      if (idRol == 4) { // Paciente
        query = query.eq('id_paciente', idUsuario);
      } else if (idRol == 3) { // Médico
        query = query.eq('id_medico', idUsuario);
      }
      
      // Ordenar por fecha_hora descendente
      final response = await query.order('fecha_hora', ascending: false);
      return (response as List).map((json) => CitaModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener las citas: $e');
    }
  }

  @override
  Future<void> actualizarEstadoCita(int idCita, String nuevoEstado) async {
    try {
      await supabaseClient
          .from('cita')
          .update({'estado': nuevoEstado})
          .eq('id_cita', idCita);
    } catch (e) {
      throw Exception('Error al actualizar el estado de la cita: $e');
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> escucharCambiosCitas() {
    return supabaseClient
        .from('cita')
        .stream(primaryKey: ['id_cita']);
  }
}
