import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/models/usuario_model.dart';
import '../../../citas/data/models/cita_model.dart';
import '../../data/models/historial_clinico_model.dart';
import '../blocs/historial_clinico_bloc.dart';
import '../blocs/historial_clinico_event.dart';
import '../blocs/historial_clinico_state.dart';

class HistorialClinicoCitaScreen extends StatefulWidget {
  final CitaModel cita;
  final UsuarioModel usuario;

  const HistorialClinicoCitaScreen({
    super.key,
    required this.cita,
    required this.usuario,
  });

  @override
  State<HistorialClinicoCitaScreen> createState() =>
      _HistorialClinicoCitaScreenState();
}

class _HistorialClinicoCitaScreenState
    extends State<HistorialClinicoCitaScreen> {
  final _diagnosticoController = TextEditingController();
  final _tratamientoController = TextEditingController();

  bool get _puedeEditar {
    return widget.usuario.idRol == 3 &&
        widget.usuario.idUsuario == widget.cita.idMedico &&
        (widget.cita.estado == 'aceptado' || widget.cita.estado == 'realizado');
  }

  @override
  void initState() {
    super.initState();
    context.read<HistorialClinicoBloc>().add(
      CargarHistorialPorCitaEvent(idCita: widget.cita.idCita!),
    );
  }

  @override
  void dispose() {
    _diagnosticoController.dispose();
    _tratamientoController.dispose();
    super.dispose();
  }

  void _guardar() {
    final diagnostico = _diagnosticoController.text.trim();
    final tratamiento = _tratamientoController.text.trim();

    if (diagnostico.isEmpty || tratamiento.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    context.read<HistorialClinicoBloc>().add(
      CrearHistorialClinicoEvent(
        historial: HistorialClinicoModel(
          idPaciente: widget.cita.idPaciente,
          idMedico: widget.cita.idMedico,
          idCita: widget.cita.idCita,
          diagnostico: diagnostico,
          tratamiento: tratamiento,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial Clínico')),
      body: BlocConsumer<HistorialClinicoBloc, HistorialClinicoState>(
        listener: (context, state) {
          if (state is HistorialClinicoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje)),
            );
          } else if (state is HistorialClinicoCreado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Historial clínico guardado'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<HistorialClinicoBloc>().add(
              CargarHistorialPorCitaEvent(idCita: widget.cita.idCita!),
            );
          }
        },
        builder: (context, state) {
          if (state is HistorialClinicoLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HistorialClinicoPorCitaLoaded && state.historial != null) {
            return _buildVista(state.historial!);
          }

          if (_puedeEditar) {
            return _buildFormulario();
          }

          return const Center(
            child: Text('No hay historial clínico registrado para esta cita.'),
          );
        },
      ),
    );
  }

  Widget _buildVista(HistorialClinicoModel historial) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diagnóstico',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(historial.diagnostico),
                  const SizedBox(height: 24),
                  Text(
                    'Tratamiento',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(historial.tratamiento),
                  if (historial.fechaCreacion != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Registrado el ${_formatearFecha(historial.fechaCreacion!)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            controller: _diagnosticoController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Diagnóstico',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _tratamientoController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Tratamiento',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: _guardar,
              child: const Text('Guardar historial clínico'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }
}
