# Configuración de Firebase Cloud Messaging

El proyecto ya incluye la estructura para enviar notificaciones push, pero requiere que configures un proyecto en Firebase.

## Pasos

1. **Crear proyecto en Firebase**
   - Ve a [Firebase Console](https://console.firebase.google.com/).
   - Crea un nuevo proyecto o selecciona uno existente.

2. **Agregar la app Flutter**
   - Registra una app Android y/o iOS.
   - Descarga `google-services.json` (Android) y/o `GoogleService-Info.plist` (iOS).
   - Colócalos en:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`

3. **Configurar Android**
   - En `android/build.gradle` (nivel proyecto), agrega:
     ```gradle
     plugins {
       id 'com.google.gms.google-services' version '4.4.1' apply false
     }
     ```
   - En `android/app/build.gradle`, agrega:
     ```gradle
     plugins {
       id 'com.android.application'
       id 'com.google.gms.google-services'
     }
     ```

4. **Configurar iOS**
   - Abre `ios/Runner.xcworkspace` en Xcode.
   - Asegúrate de que `GoogleService-Info.plist` esté incluido en el target.
   - Habilita **Push Notifications** y **Background Modes → Remote Notifications** en capabilities.

5. **Subir clave APNs (solo iOS)**
   - En Firebase → Project Settings → Cloud Messaging, sube tu clave APNs de Apple.

6. **Probar**
   - Corre la app y revisa la consola de debug. Deberías ver el FCM Token.
   - Envía una notificación de prueba desde Firebase Console → Cloud Messaging.

## Notas importantes

- El servicio `PushNotificationService` está preparado para **no crashear** si Firebase no está configurado.
- En producción, guarda el FCM token en Supabase asociado al usuario para enviar notificaciones segmentadas.
- Las notificaciones in-app actuales (`NotificacionesBloc`) siguen funcionando independientemente de FCM.
