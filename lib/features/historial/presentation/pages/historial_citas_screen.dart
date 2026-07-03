import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/fade_in_wrapper.dart';
import '../../../../core/widgets/skeleton_list.dart';
import '../blocs/historial_bloc.dart';
import '../blocs/historial_event.dart';
import '../blocs/historial_state.dart';

class HistorialCitasScreen extends StatefulWidget {
  const HistorialCitasScreen({super.key});

  @override
  State<HistorialCitasScreen> createState() => _HistorialCitasScreenState();
}

class _HistorialCitasScreenState extends State<HistorialCitasScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HistorialBloc>().add(CargarHistorialEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Citas')),
      body: BlocConsumer<HistorialBloc, HistorialState>(
        listener: (context, state) {
          if (state is HistorialError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje)),
            );
          }
        },
        builder: (context, state) {
          if (state is HistorialLoading) {
            return const SkeletonList();
          }

          if (state is HistorialLoaded) {
            final historial = state.historial;

            if (historial.isEmpty) {
              return const EmptyState(
                icono: Icons.history_toggle_off,
                titulo: 'Sin movimientos',
                mensaje: 'No hay cambios registrados en el historial de citas.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historial.length,
              itemBuilder: (context, index) {
                final item = historial[index];
                return FadeInWrapper(
                  delay: Duration(milliseconds: index * 60),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: _IconoEstado(estado: item.estadoNuevo),
                      title: Text('Cita #${item.idCita}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.estadoAnterior.toUpperCase()} → ${item.estadoNuevo.toUpperCase()}',
                          ),
                          if (item.fechaCita != null)
                            Text(
                              'Fecha cita: ${_formatearFecha(item.fechaCita!)}',
                            ),
                          if (item.comentario != null && item.comentario!.isNotEmpty)
                            Text(
                              'Nota: ${item.comentario}',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                          Text(
                            'Cambio: ${_formatearFechaHora(item.fechaCambio)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
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

  String _formatearFechaHora(DateTime fecha) {
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '${_formatearFecha(fecha)} $hora:$minuto';
  }
}

class _IconoEstado extends StatelessWidget {
  final String estado;

  const _IconoEstado({required this.estado});

  @override
  Widget build(BuildContext context) {
    final (icono, color) = switch (estado) {
      'solicitado' => (Icons.schedule, Colors.orange),
      'aceptado' => (Icons.check_circle, Colors.green),
      'realizado' => (Icons.done_all, Colors.blue),
      'cancelado' => (Icons.cancel, Colors.red),
      _ => (Icons.help, Colors.grey),
    };

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.15),
      child: Icon(icono, color: color),
    );
  }
}
