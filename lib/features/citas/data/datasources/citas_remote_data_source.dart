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
      final userResponse = await supabaseClient.auth.getUser();
      final pacienteActual = userResponse.user?.id;
      
      // Obtener el rol del usuario actual para saber si es secretaria/admin (roles 1 y 2)
      final userData = await supabaseClient
          .from('usuario')
          .select('id_rol')
          .eq('id_usuario', pacienteActual!)
          .single();
      
      final rolActual = userData['id_rol'] as int;
      
      // Si no es admin (1) ni secretaria (2), debe ser el propio paciente quien agenda
      if (rolActual != 1 && rolActual != 2) {
        if (pacienteActual != cita.idPaciente) {
          throw Exception(
            'Permiso denegado: El ID del paciente no coincide con la sesión actual.',
          );
        }
      }

      // Validación de Choque de Horarios
      // Buscamos si existe alguna cita para el mismo médico, que esté solicitada o aprobada,
      // y que se solape con el rango de tiempo de la nueva cita.
      // Solapamiento: (A.inicio < B.fin) AND (A.fin > B.inicio)
      final citasExistentes = await supabaseClient
          .from('cita')
          .select('id_cita')
          .eq('id_medico', cita.idMedico)
          .inFilter('estado', ['solicitado', 'aprobado'])
          .lt('fecha_hora', cita.fechaHoraFin.toIso8601String())
          .gt('fecha_hora_fin', cita.fechaHora.toIso8601String());

      if (citasExistentes.isNotEmpty) {
        throw Exception('El horario seleccionado no está disponible.');
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
      // Consulta relacional: Obtenemos el id del médico, su nombre y la especialidad
      final response = await supabaseClient
          .from('medico')
          .select('id_medico, usuario(nombre_completo), especialidad(nombre)');

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
