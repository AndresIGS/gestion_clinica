import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _iniciarSesion() {
    if (_formKey.currentState!.validate()) {
      // Si el formulario es válido, disparamos el evento al BLoC
      context.read<AuthBloc>().add(
        LoginRequested(
          correo: _correoController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            // BlocConsumer escucha los estados y reacciona a ellos
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthError) {
                  // Muestra una alerta roja si hay un error
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
                      SnackBar(
                        content: Text(
                          '¡Bienvenido, ${state.usuario.nombreCompleto}!',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );

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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.local_hospital,
                        size: 80,
                        color: Color(0xFF0D47A1),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Sistema Clínico',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0D47A1),
                            ),
                      ),
                      const SizedBox(height: 48),

                      // Campo de Correo
                      TextFormField(
                        controller: _correoController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu correo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo de Contraseña
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu contraseña';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Botón de Inicio de Sesión
                      SizedBox(
                        height: 50,
                        child: FilledButton(
                          onPressed: state is AuthLoading
                              ? null
                              : _iniciarSesion,
                          child: state is AuthLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                      // ... (botón Iniciar Sesión anterior)
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text('¿No tienes cuenta? Regístrate aquí'),
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
