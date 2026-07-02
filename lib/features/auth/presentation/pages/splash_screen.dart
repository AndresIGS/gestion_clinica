import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../main.dart';
import '../../data/models/usuario_model.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

/// Pantalla de inicio que decide a dónde redirigir al usuario.
///
/// Si hay una sesión activa en Supabase, recupera los datos del usuario
/// desde la tabla pública y navega al [DashboardScreen].
/// Si no hay sesión, navega al [LoginScreen].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    await Future.delayed(const Duration(seconds: 1)); // Breve animación de splash

    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
      return;
    }

    try {
      final userData = await Supabase.instance.client
          .from('usuario')
          .select()
          .eq('id_usuario', session.user.id)
          .single();

      final usuario = UsuarioModel.fromJson(userData);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardScreen(usuario: usuario),
          ),
        );
      }
    } catch (e) {
      // Si falla la recuperación (p. ej. el usuario fue eliminado de la tabla),
      // cerramos sesión y mandamos al login.
      await Supabase.instance.client.auth.signOut();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoWhatsApp(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_hospital,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Sistema Clínico',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
