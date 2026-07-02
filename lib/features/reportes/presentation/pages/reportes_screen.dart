import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/reportes_bloc.dart';
import '../blocs/reportes_event.dart';
import '../blocs/reportes_state.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReportesBloc>().add(CargarEstadisticasEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes y Estadísticas')),
      body: BlocBuilder<ReportesBloc, ReportesState>(
        builder: (context, state) {
          if (state is ReportesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EstadisticasCargadas) {
            final datos = state.estadisticas;
            
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Estado de Citas',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      children: datos.entries.map((entry) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.analytics, color: Colors.blue),
                            title: Text(entry.key.toUpperCase()),
                            trailing: Text(
                              '${entry.value}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
            );
          }

          if (state is ReportesError) {
            return Center(child: Text('Error: ${state.mensaje}'));
          }

          return const Center(child: Text('Iniciando...'));
        },
      ),
    );
  }
}
