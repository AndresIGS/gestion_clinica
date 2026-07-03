import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/horario_medico_model.dart';

abstract class HorariosMedicoRemoteDataSource {
  Future<List<HorarioMedicoModel>> obtenerHorarios(String idMedico);
  Future<void> crearHorario(HorarioMedicoModel horario);
  Future<void> actualizarHorario(HorarioMedicoModel horario);
  Future<void> eliminarHorario(int idHorario);
}

class HorariosMedicoRemoteDataSourceImpl
    implements HorariosMedicoRemoteDataSource {
  final SupabaseClient supabaseClient;

  HorariosMedicoRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<HorarioMedicoModel>> obtenerHorarios(String idMedico) async {
    final response = await supabaseClient
        .from('horario_medico')
        .select()
        .eq('id_medico', idMedico)
        .order('dia_semana')
        .order('hora_inicio');

    return (response as List)
        .map((json) => HorarioMedicoModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> crearHorario(HorarioMedicoModel horario) async {
    await supabaseClient.from('horario_medico').insert(horario.toJson());
  }

  @override
  Future<void> actualizarHorario(HorarioMedicoModel horario) async {
    final idHorario = horario.idHorario;
    if (idHorario == null) {
      throw Exception('El horario no tiene ID');
    }

    await supabaseClient
        .from('horario_medico')
        .update(horario.toJson())
        .eq('id_horario', idHorario);
  }

  @override
  Future<void> eliminarHorario(int idHorario) async {
    await supabaseClient
        .from('horario_medico')
        .delete()
        .eq('id_horario', idHorario);
  }
}
