import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ReportesRemoteDataSource {
  /// Obtiene el conteo de citas por estado aplicando filtros opcionales.
  ///
  /// [idMedico] filtra por el UUID del médico.
  /// [fechaInicio] y [fechaFin] filtran el rango de `fecha_hora`.
  Future<Map<String, int>> obtenerEstadisticasCitas({
    String? idMedico,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  });

  /// Devuelve la lista de médicos para el filtro de reportes.
  Future<List<Map<String, dynamic>>> obtenerMedicos();
}

class ReportesRemoteDataSourceImpl implements ReportesRemoteDataSource {
  final SupabaseClient supabaseClient;

  ReportesRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<Map<String, int>> obtenerEstadisticasCitas({
    String? idMedico,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      final estados = ['solicitado', 'aceptado', 'realizado', 'cancelado'];
      final Map<String, int> estadisticas = {};

      for (final estado in estados) {
        PostgrestFilterBuilder<int> query = supabaseClient
            .from('cita')
            .count(CountOption.exact)
            .eq('estado', estado);

        if (idMedico != null && idMedico.isNotEmpty) {
          query = query.eq('id_medico', idMedico);
        }

        if (fechaInicio != null) {
          query = query.gte('fecha_hora', fechaInicio.toIso8601String());
        }

        if (fechaFin != null) {
          // Incluimos todo el día seleccionado.
          final finDelDia = fechaFin.add(
            const Duration(hours: 23, minutes: 59, seconds: 59),
          );
          query = query.lte('fecha_hora', finDelDia.toIso8601String());
        }

        final int cantidad = await query;
        estadisticas[estado] = cantidad;
      }

      return estadisticas;
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> obtenerMedicos() async {
    try {
      final response = await supabaseClient
          .from('medico')
          .select('id_medico, usuario(nombre_completo), especialidad(nombre)')
          .order('usuario(nombre_completo)');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error al cargar médicos: $e');
    }
  }
}
