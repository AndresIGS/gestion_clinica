import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Gestiona el registro de dispositivos para notificaciones push.
///
/// Guarda el FCM token en la tabla `public.dispositivos` de Supabase,
/// permitiendo enviar notificaciones push segmentadas por usuario.
class DispositivoService {
  DispositivoService._();

  static final _supabase = Supabase.instance.client;

  /// Registra o actualiza el token FCM del usuario actual.
  static Future<void> guardarToken(String token) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      debugPrint('No hay usuario autenticado para guardar el FCM token');
      return;
    }

    try {
      final plataforma = _obtenerPlataforma();
      final modelo = await _obtenerModelo();

      await _supabase.from('dispositivos').upsert(
        {
          'id_usuario': user.id,
          'fcm_token': token,
          'plataforma': plataforma,
          'modelo': modelo,
          'fecha_registro': DateTime.now().toIso8601String(),
        },
        onConflict: 'fcm_token',
      );

      debugPrint('FCM token guardado en Supabase para el usuario ${user.id}');
    } catch (e) {
      debugPrint('Error al guardar FCM token: $e');
    }
  }

  /// Elimina el token FCM del usuario actual (útil al cerrar sesión).
  static Future<void> eliminarToken(String token) async {
    try {
      await _supabase
          .from('dispositivos')
          .delete()
          .eq('fcm_token', token);
    } catch (e) {
      debugPrint('Error al eliminar FCM token: $e');
    }
  }

  static String _obtenerPlataforma() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'desconocido';
  }

  static Future<String?> _obtenerModelo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        return webInfo.browserName.name;
      }
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.model;
      }
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.utsname.machine;
      }
    } catch (e) {
      debugPrint('No se pudo obtener modelo del dispositivo: $e');
    }
    return null;
  }
}
