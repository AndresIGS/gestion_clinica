import 'package:flutter/material.dart';
import 'package:sistemav2/features/citas/presentation/blocs/citas/citas_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart'
    as di; // Importamos la inyección de dependencias
import 'features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/notificaciones/presentation/blocs/notificaciones_bloc.dart';
import 'features/reportes/presentation/blocs/reportes_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa la conexión con Supabase
  await Supabase.initialize(
    url: 'https://thzgbupgkiqivcemhhlx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoemdidXBna2lxaXZjZW1oaGx4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI5NTc0NzQsImV4cCI6MjA5ODUzMzQ3NH0.E-apczy9_hJPEYHn8qBxZGWT6gDmLEr3eWVOubMXJyY',
  );

  // Inicializa la Inyección de Dependencias (Singleton)
  await di.init();

  runApp(const ClinicaApp());
}

class ClinicaApp extends StatelessWidget {
  const ClinicaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiBlocProvider permite que los BLoCs estén disponibles en toda la app
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        // Proveemos el BLoC de citas para que cualquier pantalla pueda usarlo
        BlocProvider(create: (_) => di.sl<CitasBloc>()),
        BlocProvider(create: (_) => di.sl<NotificacionesBloc>()),
        BlocProvider(create: (_) => di.sl<ReportesBloc>()),
      ],
      child: MaterialApp(
        title: 'Gestión Clínica',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Configuramos el Morado como color principal
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        // Cambiamos el texto de prueba por nuestra nueva pantalla de Login
        home: const LoginScreen(),
      ),
    );
  }
}

class FondoWhatsApp extends StatelessWidget {
  final Widget child;
  const FondoWhatsApp({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/whatsapp_bg.png'),
          repeat: ImageRepeat.repeat, // Esto hace que el fondo se repita como en los chats
          opacity: 0.1, // Opacidad baja para que no estorbe la lectura
        ),
      ),
      child: child,
    );
  }
}
