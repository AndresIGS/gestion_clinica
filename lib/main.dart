import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sistemav2/features/citas/presentation/blocs/citas/citas_bloc.dart';
import 'package:sistemav2/features/historial/presentation/blocs/historial_bloc.dart';
import 'package:sistemav2/features/historial_clinico/presentation/blocs/historial_clinico_bloc.dart';
import 'package:sistemav2/features/horarios_medico/presentation/blocs/horarios_medico_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'injection_container.dart'
    as di; // Importamos la inyección de dependencias
import 'features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'features/auth/presentation/pages/splash_screen.dart';
import 'features/notificaciones/presentation/blocs/notificaciones_bloc.dart';
import 'features/perfil/presentation/blocs/perfil_bloc.dart';
import 'features/reportes/presentation/blocs/reportes_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga las variables de entorno según el ambiente
  final envFile = kDebugMode ? '.env.dev' : '.env.prod';
  await dotenv.load(fileName: envFile);

  // Inicializa la conexión con Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
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
        BlocProvider(create: (_) => di.sl<HistorialBloc>()),
        BlocProvider(create: (_) => di.sl<HistorialClinicoBloc>()),
        BlocProvider(create: (_) => di.sl<HorariosMedicoBloc>()),
        BlocProvider(create: (_) => di.sl<NotificacionesBloc>()),
        BlocProvider(create: (_) => di.sl<PerfilBloc>()),
        BlocProvider(create: (_) => di.sl<ReportesBloc>()),
      ],
      child: MaterialApp(
        title: 'Gestión Clínica',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // El splash verifica si hay sesión activa y redirige al login o dashboard
        home: const SplashScreen(),
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
