import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/models/usuario_model.dart';
import '../../data/models/cita_model.dart';
import '../blocs/citas/citas_bloc.dart';
import '../blocs/citas/citas_event.dart';
import '../blocs/citas/citas_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AgendarCitaScreen extends StatefulWidget {
  final UsuarioModel paciente;

  const AgendarCitaScreen({super.key, required this.paciente});

  @override
  State<AgendarCitaScreen> createState() => _AgendarCitaScreenState();
}

class _AgendarCitaScreenState extends State<AgendarCitaScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _idMedicoSeleccionado;
  String? _idPacienteSeleccionado;
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  final _motivoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargamos los médicos al entrar a la pantalla
    context.read<CitasBloc>().add(CargarMedicosEvent());
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  void _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null) {
      setState(() => _fechaSeleccionada = fecha);
    }
  }

  void _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (hora != null) {
      setState(() => _horaSeleccionada = hora);
    }
  }

  void _agendarCita() {
    final bool esSecretaria =
        widget.paciente.idRol == 1 || widget.paciente.idRol == 2;
    final idPacienteFinal = esSecretaria
        ? _idPacienteSeleccionado
        : widget.paciente.idUsuario;

    if (_formKey.currentState!.validate() &&
        _fechaSeleccionada != null &&
        _horaSeleccionada != null &&
        _idMedicoSeleccionado != null &&
        idPacienteFinal != null) {
      final fechaHora = DateTime(
        _fechaSeleccionada!.year,
        _fechaSeleccionada!.month,
        _fechaSeleccionada!.day,
        _horaSeleccionada!.hour,
        _horaSeleccionada!.minute,
      );

      // Asumimos 30 minutos de duración por cita
      final fechaHoraFin = fechaHora.add(const Duration(minutes: 30));

      final nuevaCita = CitaModel(
        idPaciente: idPacienteFinal,
        idMedico: _idMedicoSeleccionado!,
        fechaHora: fechaHora,
        fechaHoraFin: fechaHoraFin,
        estado: 'solicitado',
        motivo: _motivoController.text.trim(),
      );

      context.read<CitasBloc>().add(SolicitarCitaEvent(cita: nuevaCita));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos correctamente.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar Cita')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocConsumer<CitasBloc, CitasState>(
            listener: (context, state) {
              if (state is CitasError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.mensaje),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is CitaSolicitadaExito) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.mensaje),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context); // Vuelve al listado/dashboard
              }
            },
            builder: (context, state) {
              List<Map<String, dynamic>> medicos = [];
              if (state is MedicosCargados) {
                medicos = state.medicos;
              } else if (state is CitasListadas) {
                // Ignore, we are not loading medicos
              } else if (state is CitaEstadoActualizado) {
                // Ignore
              }

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        if (state is CitasLoading)
                          const Center(child: CircularProgressIndicator()),

                        const SizedBox(height: 16),

                        // Selector de Paciente (Solo para Secretarias/Admin)
                        if (widget.paciente.idRol == 1 ||
                            widget.paciente.idRol == 2) ...[
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: Supabase.instance.client
                                .from('usuario')
                                .select('id_usuario, nombre_completo')
                                .eq('id_rol', 4), // 4 es Paciente
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              }
                              return DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Paciente Destinatario',
                                  border: OutlineInputBorder(),
                                ),
                                value: _idPacienteSeleccionado,
                                items: snapshot.data!.map((pac) {
                                  return DropdownMenuItem<String>(
                                    value: pac['id_usuario'],
                                    child: Text(
                                      pac['nombre_completo'].toString(),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(
                                  () => _idPacienteSeleccionado = val,
                                ),
                                validator: (val) =>
                                    val == null ? 'Requerido' : null,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Doctores Disponibles',
                            border: OutlineInputBorder(),
                          ),
                          value: _idMedicoSeleccionado,
                          items: medicos.map((medico) {
                            return DropdownMenuItem<String>(
                              value: medico['id_medico'],
                              child: Text(
                                'Dr. ${medico['usuario']['nombre_completo']} - ${medico['especialidad']['nombre']}',
                              ),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _idMedicoSeleccionado = val),
                          validator: (val) => val == null ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.calendar_today),
                                label: Text(
                                  _fechaSeleccionada == null
                                      ? 'Seleccionar Fecha'
                                      : '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}',
                                ),
                                onPressed: _seleccionarFecha,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.access_time),
                                label: Text(
                                  _horaSeleccionada == null
                                      ? 'Seleccionar Hora'
                                      : _horaSeleccionada!.format(context),
                                ),
                                onPressed: _seleccionarHora,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _motivoController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Motivo de la consulta',
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          height: 50,
                          child: FilledButton(
                            onPressed: state is CitasLoading
                                ? null
                                : _agendarCita,
                            child: const Text('Solicitar Cita'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
