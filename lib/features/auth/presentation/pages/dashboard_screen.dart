import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/auth/data/models/usuario_model.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import 'login_screen.dart';
import '../../../../features/citas/presentation/pages/agendar_cita_screen.dart';
import '../../../../features/citas/presentation/pages/listado_citas_screen.dart';
import '../../../../features/notificaciones/presentation/blocs/notificaciones_bloc.dart';
import '../../../../features/notificaciones/presentation/blocs/notificaciones_state.dart';
import '../../../../features/notificaciones/presentation/blocs/notificaciones_event.dart';
import '../../../../features/reportes/presentation/pages/reportes_screen.dart';

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
    // Iniciar escucha de notificaciones al entrar al dashboard
    context.read<NotificacionesBloc>().add(
      IniciarEscuchaNotificaciones(
        idUsuario: widget.usuario.idUsuario,
        idRol: widget.usuario.idRol,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String nombreRol = '';
    switch (widget.usuario.idRol) {
      case 1:
        nombreRol = 'Administrador';
        break;
      case 2:
        nombreRol = 'Secretaria';
        break;
      case 3:
        nombreRol = 'Médico';
        break;
      case 4:
        nombreRol = 'Paciente';
        break;
      default:
        nombreRol = 'Desconocido';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Principal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
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
                content: Text('Notificación: ${state.mensaje}'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.blueAccent,
              ),
            );
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle, size: 100, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                '¡Hola, ${widget.usuario.nombreCompleto}!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Has iniciado sesión como: $nombreRol',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 250,
                height: 50,
                child: FilledButton.icon(
                  icon: const Icon(Icons.list_alt),
                  label: const Text('Mis Citas'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListadoCitasScreen(usuario: widget.usuario),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (widget.usuario.idRol == 4)
                SizedBox(
                  width: 250,
                  height: 50,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Agendar Nueva Cita'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AgendarCitaScreen(paciente: widget.usuario),
                        ),
                      );
                    },
                  ),
                ),
              if (widget.usuario.idRol == 1) // Administrador
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: SizedBox(
                    width: 250,
                    height: 50,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.bar_chart),
                      label: const Text('Ver Reportes'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReportesScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
