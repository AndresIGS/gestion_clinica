import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import 'dashboard_screen.dart';

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
  int _idRolSeleccionado = 4; // Por defecto: 4 (Paciente)

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  void _registrar() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        RegisterRequested(
          correo: _correoController.text.trim(),
          password: _passwordController.text.trim(),
          nombreCompleto: _nombreController.text.trim(),
          idRol: _idRolSeleccionado,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),
      body: SafeArea(
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
                return Form(
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
                      DropdownButtonFormField<int>(
                        value: _idRolSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Rol',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 1,
                            child: Text('Administrador'),
                          ),
                          DropdownMenuItem(value: 2, child: Text('Secretaria')),
                          DropdownMenuItem(value: 3, child: Text('Médico')),
                          DropdownMenuItem(value: 4, child: Text('Paciente')),
                        ],
                        onChanged: (value) =>
                            setState(() => _idRolSeleccionado = value!),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 50,
                        child: FilledButton(
                          onPressed: state is AuthLoading ? null : _registrar,
                          child: state is AuthLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Registrarse'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
