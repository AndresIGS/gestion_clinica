import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ReportesRemoteDataSource {
  Future<Map<String, int>> obtenerEstadisticasCitas();
}

class ReportesRemoteDataSourceImpl implements ReportesRemoteDataSource {
  final SupabaseClient supabaseClient;

  ReportesRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<Map<String, int>> obtenerEstadisticasCitas() async {
    try {
      final estados = ['solicitado', 'aceptado', 'realizado', 'cancelado'];
      Map<String, int> estadisticas = {};

      for (String estado in estados) {
        // CORRECCIÓN: Usamos .count() en lugar de .select()
        // Esto devuelve un 'int' directamente.
        final int cantidad = await supabaseClient
            .from('cita')
            .count(CountOption.exact)
            .eq('estado', estado);

        estadisticas[estado] = cantidad;
      }

      return estadisticas;
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }
}
