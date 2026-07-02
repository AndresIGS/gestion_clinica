import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import 'dashboard_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../../main.dart'; // Para FondoWhatsApp

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  int _rolSeleccionado = 4; // Por defecto: 4 (Paciente)
  int? _especialidadSeleccionada;

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
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
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),
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
                    // Validamos que esta pantalla sea la visible antes de navegar
                    if (ModalRoute.of(context)?.isCurrent == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Registro exitoso!'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // En lugar de hacer pop, vamos directo al Dashboard
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DashboardScreen(usuario: state.usuario),
                        ),
                        (route) => false,
                      );
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
                            // --- CAMPO DE TELÉFONO (Para todos) ---
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

                            // --- SELECTOR DE ROL ---
                            DropdownButtonFormField<int>(
                              value: _rolSeleccionado,
                              decoration: const InputDecoration(
                                labelText: '¿Qué tipo de usuario eres?',
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
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _rolSeleccionado = value!;
                                  if (_rolSeleccionado != 3)
                                    _especialidadSeleccionada = null;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // --- DATOS HEREDADOS (DINÁMICO) ---
                            if (_rolSeleccionado == 3)
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: Supabase.instance.client
                                    .from('especialidad')
                                    .select(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData)
                                    return const CircularProgressIndicator();

                                  return DropdownButtonFormField<int>(
                                    value: _especialidadSeleccionada,
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
                                    : const Text('Registrarse'),
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
      ), // <-- AQUÍ FALTABA ESTE CIERRE
    );
  }
}
