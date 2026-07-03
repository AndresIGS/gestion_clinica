import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cita_model.dart';

abstract class CitasRemoteDataSource {
  Future<void> solicitarCita(CitaModel cita);
  Future<List<Map<String, dynamic>>> obtenerMedicosDisponibles();
  Future<List<CitaModel>> obtenerCitas(
    String idUsuario,
    int idRol, {
    int limit = 20,
    int offset = 0,
    String? estado,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  });
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
          .inFilter('estado', ['solicitado', 'aceptado'])
          .lt('fecha_hora', cita.fechaHoraFin.toIso8601String())
          .gt('fecha_hora_fin', cita.fechaHora.toIso8601String());

      if (citasExistentes.isNotEmpty) {
        throw Exception('El horario seleccionado no está disponible.');
      }

      // Validación de Horario del Médico
      final dentroDeHorario = await _validarHorarioMedico(cita);
      if (!dentroDeHorario) {
        throw Exception(
          'El médico no atiende en el horario seleccionado.',
        );
      }

      // Insertamos la cita. El Trigger de SQL creará el Historial automáticamente
      await supabaseClient.from('cita').insert(cita.toJson());
    } catch (e) {
      throw Exception('Error al agendar la cita: $e');
    }
  }

  Future<bool> _validarHorarioMedico(CitaModel cita) async {
    final diaSemana = cita.fechaHora.weekday;

    final horarios = await supabaseClient
        .from('horario_medico')
        .select('hora_inicio, hora_fin')
        .eq('id_medico', cita.idMedico)
        .eq('dia_semana', diaSemana)
        .eq('activo', true);

    if (horarios.isEmpty) {
      // Si no hay horarios configurados, permitimos por defecto
      // o podríamos rechazar. Por seguridad, permitimos para no bloquear.
      return true;
    }

    final inicioCita = _timeFromDateTime(cita.fechaHora);
    final finCita = _timeFromDateTime(cita.fechaHoraFin);

    for (final horario in horarios) {
      final inicioHorario = _parseTime(horario['hora_inicio'] as String);
      final finHorario = _parseTime(horario['hora_fin'] as String);

      if (inicioCita >= inicioHorario && finCita <= finHorario) {
        return true;
      }
    }

    return false;
  }

  int _timeFromDateTime(DateTime fecha) {
    return fecha.hour * 60 + fecha.minute;
  }

  int _parseTime(String hora) {
    final partes = hora.split(':');
    final h = int.parse(partes[0]);
    final m = int.parse(partes[1]);
    return h * 60 + m;
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
  Future<List<CitaModel>> obtenerCitas(
    String idUsuario,
    int idRol, {
    int limit = 20,
    int offset = 0,
    String? estado,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      var query = supabaseClient.from('cita').select();

      // Aplicar filtros según el rol localmente si fuera necesario,
      // aunque el RLS de Supabase ya filtra automáticamente a nivel de DB.
      // Por si acaso, lo reforzamos aquí para la vista.
      if (idRol == 4) {
        // Paciente
        query = query.eq('id_paciente', idUsuario);
      } else if (idRol == 3) {
        // Médico
        query = query.eq('id_medico', idUsuario);
      }

      if (estado != null && estado.isNotEmpty) {
        query = query.eq('estado', estado);
      }

      if (fechaInicio != null) {
        query = query.gte('fecha_hora', fechaInicio.toIso8601String());
      }

      if (fechaFin != null) {
        final finDelDia = fechaFin.add(
          const Duration(hours: 23, minutes: 59, seconds: 59),
        );
        query = query.lte('fecha_hora', finDelDia.toIso8601String());
      }

      // Ordenar por fecha_hora descendente y paginar
      final response = await query
          .order('fecha_hora', ascending: false)
          .range(offset, offset + limit - 1);

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
