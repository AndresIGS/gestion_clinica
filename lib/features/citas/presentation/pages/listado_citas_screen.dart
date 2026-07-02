import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/models/usuario_model.dart';
import '../../../historial_clinico/presentation/pages/historial_clinico_cita_screen.dart';
import '../../data/models/cita_model.dart';
import '../blocs/citas/citas_bloc.dart';
import '../blocs/citas/citas_event.dart';
import '../blocs/citas/citas_state.dart';

class ListadoCitasScreen extends StatefulWidget {
  final UsuarioModel usuario;

  const ListadoCitasScreen({super.key, required this.usuario});

  @override
  State<ListadoCitasScreen> createState() => _ListadoCitasScreenState();
}

class _ListadoCitasScreenState extends State<ListadoCitasScreen> {
  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  void _cargarCitas() {
    context.read<CitasBloc>().add(CargarCitasEvent(
          idUsuario: widget.usuario.idUsuario,
          idRol: widget.usuario.idRol,
        ));
  }

  void _actualizarEstado(int idCita, String nuevoEstado) {
    context.read<CitasBloc>().add(ActualizarEstadoCitaEvent(
          idCita: idCita,
          nuevoEstado: nuevoEstado,
        ));
  }

  void _verHistorialClinico(CitaModel cita) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HistorialClinicoCitaScreen(
          cita: cita,
          usuario: widget.usuario,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Citas')),
      body: BlocConsumer<CitasBloc, CitasState>(
        listener: (context, state) {
          if (state is CitasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje), backgroundColor: Colors.red),
            );
          } else if (state is CitaEstadoActualizado) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje), backgroundColor: Colors.green),
            );
            // Recargar citas después de actualizar
            _cargarCitas();
          }
        },
        builder: (context, state) {
          if (state is CitasLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CitasListadas) {
            final citas = state.citas;
            if (citas.isEmpty) {
              return const Center(child: Text('No hay citas registradas.'));
            }

            return ListView.builder(
              itemCount: citas.length,
              itemBuilder: (context, index) {
                final cita = citas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('Fecha: ${cita.fechaHora.toString().substring(0, 16)}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Estado: ${cita.estado.toUpperCase()}'),
                        if (cita.motivo != null) Text('Motivo: ${cita.motivo}'),
                      ],
                    ),
                    trailing: _construirAcciones(cita),
                  ),
                );
              },
            );
          }

          return const Center(child: Text('No se pudieron cargar las citas.'));
        },
      ),
    );
  }

  Widget? _construirAcciones(CitaModel cita) {
    final rol = widget.usuario.idRol;

    List<Widget> botones = [];

    // Historial clínico: disponible para médico (aceptado/realizado)
    // y para paciente cuando la cita ya fue realizada.
    final puedeVerHistorial = (rol == 3 && cita.idMedico == widget.usuario.idUsuario &&
            (cita.estado == 'aceptado' || cita.estado == 'realizado')) ||
        (rol == 4 && cita.estado == 'realizado');

    if (puedeVerHistorial) {
      botones.add(
        IconButton(
          icon: const Icon(Icons.medical_information, color: Colors.purple),
          onPressed: () => _verHistorialClinico(cita),
          tooltip: 'Historial clínico',
        ),
      );
    }

    // Si la cita ya está cancelada o realizada, no hay más acciones de estado.
    if (cita.estado == 'cancelado' || cita.estado == 'realizado') {
      return botones.isEmpty ? null : Row(
        mainAxisSize: MainAxisSize.min,
        children: botones,
      );
    }

    // HU3: Secretaria o Médico pueden aceptar citas solicitadas
    if (cita.estado == 'solicitado' && (rol == 2 || rol == 3)) {
      botones.add(
        IconButton(
          icon: const Icon(Icons.check_circle, color: Colors.green),
          onPressed: () => _actualizarEstado(cita.idCita!, 'aceptado'),
          tooltip: 'Aceptar Cita',
        ),
      );
    }

    // HU4: Médico puede finalizar citas aceptadas
    if (cita.estado == 'aceptado' && rol == 3) {
      botones.add(
        IconButton(
          icon: const Icon(Icons.done_all, color: Colors.blue),
          onPressed: () => _actualizarEstado(cita.idCita!, 'realizado'),
          tooltip: 'Finalizar Consulta',
        ),
      );
    }

    // HU5: Todos pueden cancelar citas activas
    botones.add(
      IconButton(
        icon: const Icon(Icons.cancel, color: Colors.red),
        onPressed: () => _actualizarEstado(cita.idCita!, 'cancelado'),
        tooltip: 'Cancelar Cita',
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: botones,
    );
  }
}
