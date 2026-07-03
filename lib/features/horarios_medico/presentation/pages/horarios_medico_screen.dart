import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/horario_medico_model.dart';
import '../blocs/horarios_medico_bloc.dart';
import '../blocs/horarios_medico_event.dart';
import '../blocs/horarios_medico_state.dart';

class HorariosMedicoScreen extends StatefulWidget {
  final String idMedico;
  final bool editable;

  const HorariosMedicoScreen({
    super.key,
    required this.idMedico,
    this.editable = false,
  });

  @override
  State<HorariosMedicoScreen> createState() => _HorariosMedicoScreenState();
}

class _HorariosMedicoScreenState extends State<HorariosMedicoScreen> {
  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    context.read<HorariosMedicoBloc>().add(
      CargarHorariosMedicoEvent(idMedico: widget.idMedico),
    );
  }

  Future<void> _mostrarFormulario({HorarioMedicoModel? horario}) async {
    final resultado = await showModalBottomSheet<HorarioMedicoModel>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FormularioHorario(
        horario: horario,
        idMedico: widget.idMedico,
      ),
    );

    if (resultado != null && mounted) {
      if (horario == null) {
        context.read<HorariosMedicoBloc>().add(
          CrearHorarioMedicoEvent(horario: resultado),
        );
      } else {
        context.read<HorariosMedicoBloc>().add(
          ActualizarHorarioMedicoEvent(horario: resultado),
        );
      }
    }
  }

  void _eliminar(HorarioMedicoModel horario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar horario'),
        content: const Text('¿Estás seguro de eliminar este horario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<HorariosMedicoBloc>().add(
                EliminarHorarioMedicoEvent(
                  idHorario: horario.idHorario!,
                ),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Horarios del Médico')),
      floatingActionButton: widget.editable
          ? FloatingActionButton(
              onPressed: () => _mostrarFormulario(),
              child: const Icon(Icons.add),
            )
          : null,
      body: BlocConsumer<HorariosMedicoBloc, HorariosMedicoState>(
        listener: (context, state) {
          if (state is HorariosMedicoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje)),
            );
          } else if (state is HorarioMedicoOperacionExitosa) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Operación exitosa'),
                backgroundColor: Colors.green,
              ),
            );
            _cargar();
          }
        },
        builder: (context, state) {
          if (state is HorariosMedicoLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HorariosMedicoLoaded) {
            final horarios = state.horarios;

            if (horarios.isEmpty) {
              return const Center(
                child: Text('No hay horarios configurados.'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: horarios.length,
              itemBuilder: (context, index) {
                final h = horarios[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${h.diaSemana}'),
                    ),
                    title: Text(h.nombreDia),
                    subtitle: Text('${h.horaInicio} - ${h.horaFin}'),
                    trailing: widget.editable
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _mostrarFormulario(horario: h),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _eliminar(h),
                              ),
                            ],
                          )
                        : null,
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
}

class _FormularioHorario extends StatefulWidget {
  final HorarioMedicoModel? horario;
  final String idMedico;

  const _FormularioHorario({this.horario, required this.idMedico});

  @override
  State<_FormularioHorario> createState() => _FormularioHorarioState();
}

class _FormularioHorarioState extends State<_FormularioHorario> {
  late int _diaSeleccionado;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;

  @override
  void initState() {
    super.initState();
    _diaSeleccionado = widget.horario?.diaSemana ?? 1;
    if (widget.horario != null) {
      _horaInicio = _parseTime(widget.horario!.horaInicio);
      _horaFin = _parseTime(widget.horario!.horaFin);
    }
  }

  TimeOfDay _parseTime(String hora) {
    final partes = hora.split(':');
    return TimeOfDay(
      hour: int.parse(partes[0]),
      minute: int.parse(partes[1]),
    );
  }

  String _formatTime(TimeOfDay hora) {
    final h = hora.hour.toString().padLeft(2, '0');
    final m = hora.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  Future<void> _seleccionarHoraInicio() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaInicio ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (hora != null) setState(() => _horaInicio = hora);
  }

  Future<void> _seleccionarHoraFin() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaFin ?? const TimeOfDay(hour: 17, minute: 0),
    );
    if (hora != null) setState(() => _horaFin = hora);
  }

  void _guardar() {
    if (_horaInicio == null || _horaFin == null) return;

    final inicioMinutos = _horaInicio!.hour * 60 + _horaInicio!.minute;
    final finMinutos = _horaFin!.hour * 60 + _horaFin!.minute;

    if (finMinutos <= inicioMinutos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La hora fin debe ser mayor a la inicio')),
      );
      return;
    }

    Navigator.pop(
      context,
      HorarioMedicoModel(
        idHorario: widget.horario?.idHorario,
        idMedico: widget.idMedico,
        diaSemana: _diaSeleccionado,
        horaInicio: _formatTime(_horaInicio!),
        horaFin: _formatTime(_horaFin!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.horario == null ? 'Nuevo Horario' : 'Editar Horario',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: _diaSeleccionado,
            decoration: const InputDecoration(labelText: 'Día de la semana'),
            items: const [
              DropdownMenuItem(value: 1, child: Text('Lunes')),
              DropdownMenuItem(value: 2, child: Text('Martes')),
              DropdownMenuItem(value: 3, child: Text('Miércoles')),
              DropdownMenuItem(value: 4, child: Text('Jueves')),
              DropdownMenuItem(value: 5, child: Text('Viernes')),
              DropdownMenuItem(value: 6, child: Text('Sábado')),
              DropdownMenuItem(value: 7, child: Text('Domingo')),
            ],
            onChanged: (val) => setState(() => _diaSeleccionado = val!),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: Text(_horaInicio == null
                      ? 'Hora inicio'
                      : _horaInicio!.format(context)),
                  onPressed: _seleccionarHoraInicio,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: Text(_horaFin == null
                      ? 'Hora fin'
                      : _horaFin!.format(context)),
                  onPressed: _seleccionarHoraFin,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: _guardar,
              child: const Text('Guardar'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
