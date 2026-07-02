import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/historial_cita_model.dart';

abstract class HistorialRemoteDataSource {
  Future<List<HistorialCitaModel>> obtenerHistorial();
}

class HistorialRemoteDataSourceImpl implements HistorialRemoteDataSource {
  final SupabaseClient supabaseClient;

  HistorialRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<HistorialCitaModel>> obtenerHistorial() async {
    final response = await supabaseClient
        .from('historial_cita')
        .select('''
          id_historial,
          id_cita,
          id_usuario_accion,
          estado_anterior,
          estado_nuevo,
          comentario,
          fecha_cambio,
          cita(fecha_hora, id_paciente, id_medico)
        ''')
        .order('fecha_cambio', ascending: false);

    return (response as List)
        .map((json) => HistorialCitaModel.fromJson(json))
        .toList();
  }
}
