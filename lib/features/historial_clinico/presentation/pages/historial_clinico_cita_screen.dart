import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/storage_service.dart';
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

  XFile? _archivoSeleccionado;
  bool _subiendo = false;

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

  Future<void> _seleccionarArchivo() async {
    final archivo = await StorageService.seleccionarImagen();
    if (archivo != null) {
      setState(() => _archivoSeleccionado = archivo);
    }
  }

  Future<void> _guardar() async {
    final diagnostico = _diagnosticoController.text.trim();
    final tratamiento = _tratamientoController.text.trim();

    if (diagnostico.isEmpty || tratamiento.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    List<String> adjuntos = [];

    if (_archivoSeleccionado != null) {
      setState(() => _subiendo = true);
      final url = await StorageService.subirAdjuntoHistorial(
        archivo: _archivoSeleccionado!,
        idPaciente: widget.cita.idPaciente,
      );
      setState(() => _subiendo = false);

      if (url != null) {
        adjuntos.add(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo subir el archivo. Intenta de nuevo.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    if (mounted) {
      context.read<HistorialClinicoBloc>().add(
        CrearHistorialClinicoEvent(
          historial: HistorialClinicoModel(
            idPaciente: widget.cita.idPaciente,
            idMedico: widget.cita.idMedico,
            idCita: widget.cita.idCita,
            diagnostico: diagnostico,
            tratamiento: tratamiento,
            adjuntos: adjuntos,
          ),
        ),
      );
    }
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
            setState(() => _archivoSeleccionado = null);
            context.read<HistorialClinicoBloc>().add(
              CargarHistorialPorCitaEvent(idCita: widget.cita.idCita!),
            );
          }
        },
        builder: (context, state) {
          if (state is HistorialClinicoLoading && !_subiendo) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HistorialClinicoPorCitaLoaded &&
              state.historial != null) {
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
          if (historial.adjuntos.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Adjuntos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...historial.adjuntos.map((url) => Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {}, // Aquí podrías abrir visor de imagen
                    child: Image.network(
                      url,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const ListTile(
                        leading: Icon(Icons.image_not_supported),
                        title: Text('No se pudo cargar la imagen'),
                      ),
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildFormulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          OutlinedButton.icon(
            icon: const Icon(Icons.attach_file),
            label: Text(_archivoSeleccionado == null
                ? 'Adjuntar imagen'
                : 'Cambiar imagen'),
            onPressed: _seleccionarArchivo,
          ),
          if (_archivoSeleccionado != null) ...[
            const SizedBox(height: 12),
            Text(
              'Archivo: ${_archivoSeleccionado!.name}',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: _subiendo ? null : _guardar,
              child: _subiendo
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Guardar historial clínico'),
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
