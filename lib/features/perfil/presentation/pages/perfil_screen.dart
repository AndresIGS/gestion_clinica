import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/models/usuario_model.dart';
import '../blocs/perfil_bloc.dart';
import '../blocs/perfil_event.dart';
import '../blocs/perfil_state.dart';

class PerfilScreen extends StatefulWidget {
  final UsuarioModel usuario;

  const PerfilScreen({super.key, required this.usuario});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late final TextEditingController _nombreController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _correoController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.usuario.nombreCompleto);
    _telefonoController = TextEditingController(text: widget.usuario.telefono ?? '');
    _correoController = TextEditingController(text: widget.usuario.correo);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  void _guardar() {
    context.read<PerfilBloc>().add(
      ActualizarPerfilEvent(
        nombreCompleto: _nombreController.text.trim(),
        telefono: _telefonoController.text.trim(),
      ),
    );
  }

  String _nombreRol(int idRol) {
    return switch (idRol) {
      1 => 'Administrador',
      2 => 'Secretaria',
      3 => 'Médico',
      4 => 'Paciente',
      _ => 'Desconocido',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: BlocConsumer<PerfilBloc, PerfilState>(
        listener: (context, state) {
          if (state is PerfilError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje)),
            );
          } else if (state is PerfilActualizado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil actualizado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    widget.usuario.nombreCompleto.isNotEmpty
                        ? widget.usuario.nombreCompleto[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre completo',
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _telefonoController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono',
                            prefixIcon: Icon(Icons.phone),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _correoController,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                        const SizedBox(height: 16),
                        InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Rol',
                            prefixIcon: Icon(Icons.badge),
                          ),
                          child: Text(_nombreRol(widget.usuario.idRol)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: state is PerfilLoading ? null : _guardar,
                    child: state is PerfilLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Guardar cambios'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
