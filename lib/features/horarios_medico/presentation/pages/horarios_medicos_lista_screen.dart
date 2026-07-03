import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/navigation/app_router.dart';
import 'horarios_medico_screen.dart';

class HorariosMedicosListaScreen extends StatefulWidget {
  const HorariosMedicosListaScreen({super.key});

  @override
  State<HorariosMedicosListaScreen> createState() =>
      _HorariosMedicosListaScreenState();
}

class _HorariosMedicosListaScreenState
    extends State<HorariosMedicosListaScreen> {
  Future<List<Map<String, dynamic>>> _cargarMedicos() async {
    final response = await Supabase.instance.client
        .from('medico')
        .select('id_medico, usuario(nombre_completo), especialidad(nombre)')
        .order('usuario(nombre_completo)');

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar Médico')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cargarMedicos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final medicos = snapshot.data ?? [];

          if (medicos.isEmpty) {
            return const Center(child: Text('No hay médicos registrados.'));
          }

          return ListView.builder(
            itemCount: medicos.length,
            itemBuilder: (context, index) {
              final medico = medicos[index];
              final nombre = medico['usuario']['nombre_completo'] as String;
              final especialidad = medico['especialidad']['nombre'] as String;

              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text('Dr. $nombre'),
                subtitle: Text(especialidad),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    AppRouter.slide(
                      HorariosMedicoScreen(
                        idMedico: medico['id_medico'] as String,
                        editable: true,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
