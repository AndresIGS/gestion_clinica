import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/fade_in_wrapper.dart';
import '../../../../features/auth/data/models/usuario_model.dart';
import '../../../../features/citas/data/models/cita_model.dart';
import '../../../../features/citas/presentation/blocs/citas/citas_bloc.dart';
import '../../../../features/citas/presentation/blocs/citas/citas_event.dart';
import '../../../../features/citas/presentation/blocs/citas/citas_state.dart';
import '../../../../features/citas/presentation/pages/agendar_cita_screen.dart';
import '../../../../features/citas/presentation/pages/listado_citas_screen.dart';
import '../../../../features/notificaciones/presentation/blocs/notificaciones_bloc.dart';
import '../../../../features/notificaciones/presentation/blocs/notificaciones_event.dart';
import '../../../../features/notificaciones/presentation/blocs/notificaciones_state.dart';
import '../../../../features/historial/presentation/pages/historial_citas_screen.dart';
import '../../../../features/historial_clinico/presentation/pages/historial_clinico_paciente_screen.dart';
import '../../../../features/horarios_medico/presentation/pages/horarios_medico_screen.dart';
import '../../../../features/horarios_medico/presentation/pages/horarios_medicos_lista_screen.dart';
import '../../../../features/perfil/presentation/pages/perfil_screen.dart';
import 'register_screen.dart';
import '../../../../features/reportes/presentation/pages/reportes_screen.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final UsuarioModel usuario;

  const DashboardScreen({super.key, required this.usuario});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _cargarCitas();
    _iniciarNotificaciones();
  }

  void _cargarCitas() {
    context.read<CitasBloc>().add(
      CargarCitasEvent(
        idUsuario: widget.usuario.idUsuario,
        idRol: widget.usuario.idRol,
      ),
    );
  }

  void _iniciarNotificaciones() {
    context.read<NotificacionesBloc>().add(
      IniciarEscuchaNotificaciones(
        idUsuario: widget.usuario.idUsuario,
        idRol: widget.usuario.idRol,
      ),
    );
  }

  String get _nombreRol {
    return switch (widget.usuario.idRol) {
      1 => 'Administrador',
      2 => 'Secretaria',
      3 => 'Médico',
      4 => 'Paciente',
      _ => 'Desconocido',
    };
  }

  List<_AccesoRapido> _accesosPorRol(BuildContext context) {
    final accesos = <_AccesoRapido>[
      _AccesoRapido(
        icono: Icons.list_alt,
        titulo: 'Mis Citas',
        onTap: () => _irA(
          ListadoCitasScreen(usuario: widget.usuario),
        ),
      ),
    ];

    if (widget.usuario.idRol == 4) {
      accesos.add(
        _AccesoRapido(
          icono: Icons.add_circle_outline,
          titulo: 'Agendar Cita',
          onTap: () => _irA(
            AgendarCitaScreen(paciente: widget.usuario),
          ),
        ),
      );
      accesos.add(
        _AccesoRapido(
          icono: Icons.medical_information,
          titulo: 'Mi Historial Clínico',
          onTap: () => _irA(
            HistorialClinicoPacienteScreen(paciente: widget.usuario),
          ),
        ),
      );
    }

    if (widget.usuario.idRol == 1 || widget.usuario.idRol == 2) {
      accesos.add(
        _AccesoRapido(
          icono: Icons.person_add_alt,
          titulo: 'Agendar (Paciente)',
          onTap: () => _irA(
            AgendarCitaScreen(paciente: widget.usuario),
          ),
        ),
      );
    }

    if (widget.usuario.idRol == 1 || widget.usuario.idRol == 2 || widget.usuario.idRol == 3) {
      accesos.add(
        _AccesoRapido(
          icono: Icons.history,
          titulo: 'Historial',
          onTap: () => _irA(const HistorialCitasScreen()),
        ),
      );
    }

    if (widget.usuario.idRol == 3) {
      accesos.add(
        _AccesoRapido(
          icono: Icons.schedule,
          titulo: 'Mis Horarios',
          onTap: () => _irA(HorariosMedicoScreen(idMedico: widget.usuario.idUsuario)),
        ),
      );
    }

    if (widget.usuario.idRol == 1 || widget.usuario.idRol == 2) {
      accesos.add(
        _AccesoRapido(
          icono: Icons.edit_calendar,
          titulo: 'Gestionar Horarios',
          onTap: () => _irA(const HorariosMedicosListaScreen()),
        ),
      );
    }

    if (widget.usuario.idRol == 1 || widget.usuario.idRol == 2) {
      accesos.add(
        _AccesoRapido(
          icono: Icons.person_add,
          titulo: 'Registrar Usuario',
          onTap: () => _irA(RegisterScreen(usuarioRegistrador: widget.usuario)),
        ),
      );
    }

    if (widget.usuario.idRol == 1) {
      accesos.add(
        _AccesoRapido(
          icono: Icons.bar_chart,
          titulo: 'Reportes',
          onTap: () => _irA(const ReportesScreen()),
        ),
      );
    }

    return accesos;
  }

  void _irA(Widget pantalla) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => pantalla),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Principal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Mi Perfil',
            onPressed: () => _irA(PerfilScreen(usuario: widget.usuario)),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: BlocListener<NotificacionesBloc, NotificacionesState>(
        listener: (context, state) {
          if (state is NuevaNotificacionState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.blueAccent,
              ),
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: () async => _cargarCitas(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildAccesosRapidos(),
                const SizedBox(height: 24),
                _buildProximasCitas(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                widget.usuario.nombreCompleto.isNotEmpty
                    ? widget.usuario.nombreCompleto[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola, ${widget.usuario.nombreCompleto}!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _nombreRol,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccesosRapidos() {
    final accesos = _accesosPorRol(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accesos rápidos',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: accesos.asMap().entries.map((entry) {
            final a = entry.value;
            return FadeInWrapper(
              delay: Duration(milliseconds: entry.key * 80),
              child: _AccesoRapidoCard(
                icono: a.icono,
                titulo: a.titulo,
                onTap: a.onTap,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProximasCitas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Próximas citas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () => _irA(ListadoCitasScreen(usuario: widget.usuario)),
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<CitasBloc, CitasState>(
          builder: (context, state) {
            if (state is CitasLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state is CitasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No se pudieron cargar las citas.\n${state.mensaje}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (state is CitasListadas) {
              final proximas = _proximasCitas(state.citas);

              if (proximas.isEmpty) {
                return Card(
                  child: EmptyState(
                    icono: Icons.event_available,
                    titulo: 'Sin citas próximas',
                    mensaje: widget.usuario.idRol == 4
                        ? 'Agenda tu primera cita desde el panel.'
                        : 'No tienes citas programadas para los próximos días.',
                    accion: widget.usuario.idRol == 4
                        ? FilledButton.icon(
                            onPressed: () => _irA(
                              AgendarCitaScreen(paciente: widget.usuario),
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text('Agendar'),
                          )
                        : null,
                  ),
                );
              }

              return Column(
                children: proximas
                    .map((cita) => _CitaCard(cita: cita))
                    .toList(),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  List<CitaModel> _proximasCitas(List<CitaModel> citas) {
    final ahora = DateTime.now();
    return citas
        .where((c) => c.fechaHora.isAfter(ahora))
        .toList()
      ..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
  }
}

class _CitaCard extends StatelessWidget {
  final CitaModel cita;

  const _CitaCard({required this.cita});

  @override
  Widget build(BuildContext context) {
    final fecha = cita.fechaHora;
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final hora = '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            '$dia\n$mes',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text('${cita.estado.toUpperCase()} - $hora'),
        subtitle: cita.motivo != null && cita.motivo!.isNotEmpty
            ? Text(cita.motivo!)
            : null,
        trailing: _EstadoChip(estado: cita.estado),
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  final String estado;

  const _EstadoChip({required this.estado});

  @override
  Widget build(BuildContext context) {
    final (color, icono) = switch (estado) {
      'solicitado' => (Colors.orange, Icons.schedule),
      'aceptado' => (Colors.green, Icons.check_circle),
      'realizado' => (Colors.blue, Icons.done_all),
      'cancelado' => (Colors.red, Icons.cancel),
      _ => (Colors.grey, Icons.help),
    };

    return Icon(icono, color: color);
  }
}

class _AccesoRapido {
  final IconData icono;
  final String titulo;
  final VoidCallback onTap;

  _AccesoRapido({
    required this.icono,
    required this.titulo,
    required this.onTap,
  });
}

class _AccesoRapidoCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final VoidCallback onTap;

  const _AccesoRapidoCard({
    required this.icono,
    required this.titulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
