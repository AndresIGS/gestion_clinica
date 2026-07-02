import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../../main.dart';
import '../../data/models/usuario_model.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  /// Si se proporciona, significa que un usuario autenticado (admin o secretaria)
  /// está registrando a otra persona. En ese caso se permite elegir rol.
  final UsuarioModel? usuarioRegistrador;

  const RegisterScreen({super.key, this.usuarioRegistrador});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();

  final _matriculaController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();

  late int _rolSeleccionado;
  int? _especialidadSeleccionada;

  bool get _esRegistroPublico => widget.usuarioRegistrador == null;

  bool get _permiteElegirRol {
    if (_esRegistroPublico) return false;
    final rol = widget.usuarioRegistrador!.idRol;
    return rol == 1 || rol == 2; // Admin o Secretaria
  }

  @override
  void initState() {
    super.initState();
    // En registro público forzamos Paciente.
    _rolSeleccionado = _permiteElegirRol ? 4 : 4;
  }

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    _telefonoController.dispose();
    _matriculaController.dispose();
    _fechaNacimientoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fechaNacimientoController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _registrar() {
    if (_formKey.currentState!.validate()) {
      if (_rolSeleccionado == 3 && _especialidadSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecciona una especialidad.'),
          ),
        );
        return;
      }

      context.read<AuthBloc>().add(
        RegisterRequested(
          correo: _correoController.text.trim(),
          password: _passwordController.text.trim(),
          nombreCompleto: _nombreController.text.trim(),
          idRol: _rolSeleccionado,
          telefono: _telefonoController.text.trim(),
          idEspecialidad: _especialidadSeleccionada,
          matriculaMedica: _rolSeleccionado == 3
              ? _matriculaController.text.trim()
              : null,
          fechaNacimiento: _rolSeleccionado == 4
              ? _fechaNacimientoController.text.trim()
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titulo = _esRegistroPublico ? 'Crear Cuenta' : 'Registrar Usuario';

    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: FondoWhatsApp(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.mensaje),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (state is AuthAuthenticated) {
                    if (ModalRoute.of(context)?.isCurrent == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Registro exitoso!'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      if (_esRegistroPublico) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DashboardScreen(usuario: state.usuario),
                          ),
                          (route) => false,
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    }
                  }
                },
                builder: (context, state) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _nombreController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre Completo',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _correoController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Correo',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Contraseña (min 6 caracteres)',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _telefonoController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Teléfono',
                                prefixIcon: Icon(Icons.phone),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? 'Ingresa un teléfono' : null,
                            ),
                            const SizedBox(height: 16),

                            if (_permiteElegirRol) ...[
                              DropdownButtonFormField<int>(
                                initialValue: _rolSeleccionado,
                                decoration: const InputDecoration(
                                  labelText: 'Tipo de usuario',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 4,
                                    child: Text('Paciente'),
                                  ),
                                  DropdownMenuItem(
                                    value: 3,
                                    child: Text('Médico'),
                                  ),
                                  DropdownMenuItem(
                                    value: 2,
                                    child: Text('Secretaria'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _rolSeleccionado = value!;
                                    if (_rolSeleccionado != 3) {
                                      _especialidadSeleccionada = null;
                                      _matriculaController.clear();
                                    }
                                    if (_rolSeleccionado != 4) {
                                      _fechaNacimientoController.clear();
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                            ],

                            if (_rolSeleccionado == 4) ...[
                              TextFormField(
                                controller: _fechaNacimientoController,
                                readOnly: true,
                                onTap: () => _seleccionarFecha(context),
                                decoration: const InputDecoration(
                                  labelText: 'Fecha de Nacimiento',
                                  prefixIcon: Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(),
                                  hintText: 'YYYY-MM-DD',
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Selecciona tu fecha de nacimiento'
                                    : null,
                              ),
                            ],

                            if (_rolSeleccionado == 3) ...[
                              TextFormField(
                                controller: _matriculaController,
                                decoration: const InputDecoration(
                                  labelText: 'Matrícula Médica',
                                  prefixIcon: Icon(
                                    Icons.assignment_ind_outlined,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Ingresa tu matrícula'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: Supabase.instance.client
                                    .from('especialidad')
                                    .select(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  return DropdownButtonFormField<int>(
                                    initialValue: _especialidadSeleccionada,
                                    decoration: const InputDecoration(
                                      labelText: 'Selecciona tu Especialidad',
                                      prefixIcon: Icon(
                                        Icons.medical_services_outlined,
                                      ),
                                      border: OutlineInputBorder(),
                                    ),
                                    items: snapshot.data!.map((esp) {
                                      return DropdownMenuItem<int>(
                                        value: esp['id_especialidad'] as int,
                                        child: Text(esp['nombre'].toString()),
                                      );
                                    }).toList(),
                                    onChanged: (value) => setState(
                                      () => _especialidadSeleccionada = value,
                                    ),
                                    validator: (value) => value == null
                                        ? 'Selecciona una especialidad'
                                        : null,
                                  );
                                },
                              ),
                            ],

                            const SizedBox(height: 32),
                            SizedBox(
                              height: 50,
                              child: FilledButton(
                                onPressed: state is AuthLoading
                                    ? null
                                    : _registrar,
                                child: state is AuthLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(_esRegistroPublico
                                        ? 'Registrarse'
                                        : 'Registrar usuario'),
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
        ),
      ),
    );
  }
}
