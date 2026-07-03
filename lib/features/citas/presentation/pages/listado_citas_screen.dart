import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_list.dart';
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
  static const int _limitePorPagina = 20;

  final ScrollController _scrollController = ScrollController();
  int _offsetActual = 0;
  bool _cargandoMas = false;

  String? _estadoSeleccionado;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  @override
  void initState() {
    super.initState();
    _cargarCitas();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _cargarCitas() {
    _offsetActual = 0;
    context.read<CitasBloc>().add(CargarCitasEvent(
          idUsuario: widget.usuario.idUsuario,
          idRol: widget.usuario.idRol,
          limit: _limitePorPagina,
          offset: _offsetActual,
          esPrimeraCarga: true,
          estado: _estadoSeleccionado,
          fechaInicio: _fechaInicio,
          fechaFin: _fechaFin,
        ));
  }

  void _cargarMasCitas() {
    if (_cargandoMas) return;

    _offsetActual += _limitePorPagina;
    _cargandoMas = true;
    context.read<CitasBloc>().add(CargarCitasEvent(
          idUsuario: widget.usuario.idUsuario,
          idRol: widget.usuario.idRol,
          limit: _limitePorPagina,
          offset: _offsetActual,
          esPrimeraCarga: false,
          estado: _estadoSeleccionado,
          fechaInicio: _fechaInicio,
          fechaFin: _fechaFin,
        ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<CitasBloc>().state;
      if (state is CitasListadas && state.hayMas) {
        _cargarMasCitas();
      }
    }
  }

  Future<void> _seleccionarFechaInicio() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null) {
      setState(() => _fechaInicio = fecha);
      _cargarCitas();
    }
  }

  Future<void> _seleccionarFechaFin() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null) {
      setState(() => _fechaFin = fecha);
      _cargarCitas();
    }
  }

  void _limpiarFiltros() {
    setState(() {
      _estadoSeleccionado = null;
      _fechaInicio = null;
      _fechaFin = null;
    });
    _cargarCitas();
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
            _cargarCitas();
          } else if (state is CitasListadas || state is CitasPaginando) {
            _cargandoMas = false;
          }
        },
        builder: (context, state) {
          if (state is CitasLoading && state is! CitasPaginando) {
            return const SkeletonList();
          }

          List<CitaModel> citas = [];
          bool paginando = false;

          if (state is CitasListadas) {
            citas = state.citas;
          } else if (state is CitasPaginando) {
            citas = state.citasActuales;
            paginando = true;
          }

          if (citas.isEmpty && !paginando) {
            return EmptyState(
              icono: Icons.calendar_today,
              titulo: 'No hay citas',
              mensaje: 'No se encontraron citas con los filtros seleccionados.',
              accion: widget.usuario.idRol == 4
                  ? FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Agendar cita'),
                    )
                  : null,
            );
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: citas.length + (paginando ? 1 : 0) + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildFiltros();
              }

              final realIndex = index - 1;
              if (realIndex == citas.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final cita = citas[realIndex];
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
        },
      ),
    );
  }

  Widget _buildFiltros() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _estadoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Estado',
                prefixIcon: Icon(Icons.filter_list),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Todos')),
                DropdownMenuItem(value: 'solicitado', child: Text('Solicitado')),
                DropdownMenuItem(value: 'aceptado', child: Text('Aceptado')),
                DropdownMenuItem(value: 'realizado', child: Text('Realizado')),
                DropdownMenuItem(value: 'cancelado', child: Text('Cancelado')),
              ],
              onChanged: (val) {
                setState(() => _estadoSeleccionado = val);
                _cargarCitas();
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(_fechaInicio == null
                        ? 'Desde'
                        : '${_fechaInicio!.day}/${_fechaInicio!.month}/${_fechaInicio!.year}'),
                    onPressed: _seleccionarFechaInicio,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(_fechaFin == null
                        ? 'Hasta'
                        : '${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}'),
                    onPressed: _seleccionarFechaFin,
                  ),
                ),
              ],
            ),
            if (_estadoSeleccionado != null ||
                _fechaInicio != null ||
                _fechaFin != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpiar'),
                  onPressed: _limpiarFiltros,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget? _construirAcciones(CitaModel cita) {
    final rol = widget.usuario.idRol;

    List<Widget> botones = [];

    final puedeVerHistorial = (rol == 3 &&
            cita.idMedico == widget.usuario.idUsuario &&
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

    if (cita.estado == 'cancelado' || cita.estado == 'realizado') {
      return botones.isEmpty
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: botones,
            );
    }

    if (cita.estado == 'solicitado' && (rol == 2 || rol == 3)) {
      botones.add(
        IconButton(
          icon: const Icon(Icons.check_circle, color: Colors.green),
          onPressed: () => _actualizarEstado(cita.idCita!, 'aceptado'),
          tooltip: 'Aceptar Cita',
        ),
      );
    }

    if (cita.estado == 'aceptado' && rol == 3) {
      botones.add(
        IconButton(
          icon: const Icon(Icons.done_all, color: Colors.blue),
          onPressed: () => _actualizarEstado(cita.idCita!, 'realizado'),
          tooltip: 'Finalizar Consulta',
        ),
      );
    }

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
