import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/historial_clinico_model.dart';

abstract class HistorialClinicoRemoteDataSource {
  Future<List<HistorialClinicoModel>> obtenerHistorialPorPaciente(String idPaciente);
  Future<HistorialClinicoModel?> obtenerPorCita(int idCita);
  Future<void> crearHistorial(HistorialClinicoModel historial);
}

class HistorialClinicoRemoteDataSourceImpl
    implements HistorialClinicoRemoteDataSource {
  final SupabaseClient supabaseClient;

  HistorialClinicoRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<HistorialClinicoModel>> obtenerHistorialPorPaciente(
    String idPaciente,
  ) async {
    final response = await supabaseClient
        .from('historial_clinico')
        .select()
        .eq('id_paciente', idPaciente)
        .order('fecha_creacion', ascending: false);

    return (response as List)
        .map((json) => HistorialClinicoModel.fromJson(json))
        .toList();
  }

  @override
  Future<HistorialClinicoModel?> obtenerPorCita(int idCita) async {
    final response = await supabaseClient
        .from('historial_clinico')
        .select()
        .eq('id_cita', idCita)
        .maybeSingle();

    if (response == null) return null;
    return HistorialClinicoModel.fromJson(response);
  }

  @override
  Future<void> crearHistorial(HistorialClinicoModel historial) async {
    await supabaseClient.from('historial_clinico').insert(historial.toJson());
  }
}
