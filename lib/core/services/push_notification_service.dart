import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Servicio base para notificaciones push mediante Firebase Cloud Messaging.
///
/// Este servicio está preparado para funcionar, pero requiere configuración
/// previa en la consola de Firebase (ver `docs/firebase-setup.md`).
/// Si Firebase no está configurado, el servicio no detiene la app; simplemente
/// registra el error y continúa.
class PushNotificationService {
  PushNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final StreamController<RemoteMessage> _onMessageController =
      StreamController<RemoteMessage>.broadcast();

  static Stream<RemoteMessage> get onMessage => _onMessageController.stream;

  /// Inicializa Firebase y solicita permisos de notificación.
  ///
  /// Debe llamarse una sola vez, preferentemente en `main()` después de
  /// `WidgetsFlutterBinding.ensureInitialized()`.
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint(
        'Permiso de notificaciones: ${settings.authorizationStatus}',
      );

      // Token del dispositivo. En producción deberías enviarlo a Supabase
      // para asociarlo al usuario y enviar notificaciones segmentadas.
      final token = await _messaging.getToken();
      debugPrint('FCM Token: $token');

      // Maneja mensajes mientras la app está en primer plano.
      FirebaseMessaging.onMessage.listen((message) {
        debugPrint('Mensaje en primer plano: ${message.notification?.title}');
        _onMessageController.add(message);
      });

      // Maneja mensajes que abrieron la app desde segundo plano.
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint('App abierta desde notificación: ${message.data}');
      });
    } catch (e) {
      debugPrint('Firebase no está configurado. Notificaciones push omitidas: $e');
    }
  }

  /// Cierra el stream controller al finalizar la app.
  static void dispose() {
    _onMessageController.close();
  }
}
