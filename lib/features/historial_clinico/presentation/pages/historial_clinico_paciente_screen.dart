import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/models/usuario_model.dart';
import '../blocs/historial_clinico_bloc.dart';
import '../blocs/historial_clinico_event.dart';
import '../blocs/historial_clinico_state.dart';

class HistorialClinicoPacienteScreen extends StatefulWidget {
  final UsuarioModel paciente;

  const HistorialClinicoPacienteScreen({super.key, required this.paciente});

  @override
  State<HistorialClinicoPacienteScreen> createState() =>
      _HistorialClinicoPacienteScreenState();
}

class _HistorialClinicoPacienteScreenState
    extends State<HistorialClinicoPacienteScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HistorialClinicoBloc>().add(
      CargarHistorialClinicoEvent(idPaciente: widget.paciente.idUsuario),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Historial Clínico')),
      body: BlocConsumer<HistorialClinicoBloc, HistorialClinicoState>(
        listener: (context, state) {
          if (state is HistorialClinicoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje)),
            );
          }
        },
        builder: (context, state) {
          if (state is HistorialClinicoLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HistorialClinicoLoaded) {
            if (state.historial.isEmpty) {
              return const Center(
                child: Text('No tienes registros clínicos aún.'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.historial.length,
              itemBuilder: (context, index) {
                final item = state.historial[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Diagnóstico',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(item.diagnostico),
                        const SizedBox(height: 12),
                        Text(
                          'Tratamiento',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(item.tratamiento),
                        if (item.fechaCreacion != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Fecha: ${_formatearFecha(item.fechaCreacion!)}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }
}
