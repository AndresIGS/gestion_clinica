# Configuración de Firebase Cloud Messaging + Supabase

El proyecto ya incluye la estructura para enviar notificaciones push. Supabase gestiona los datos y FCM se encarga de entregar las notificaciones a los dispositivos.

## Arquitectura

```text
Flutter app
    │
    ├─► Obtiene FCM token
    ├─► Guarda token en Supabase (tabla dispositivos)
    │
Supabase
    │
    ├─► Trigger detecta cambio en cita
    ├─► Edge Function send-push-notification
    ├─► Edge Function llama a API FCM
    │
FCM
    │
    └─► Entrega notificación al dispositivo
```

## Pasos

### 1. Crear proyecto en Firebase

- Ve a [Firebase Console](https://console.firebase.google.com/).
- Crea un nuevo proyecto o selecciona uno existente.

### 2. Registrar la app Flutter

- Registra una app Android y/o iOS.
- Descarga `google-services.json` (Android) y/o `GoogleService-Info.plist` (iOS).
- Colócalos en:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`

### 3. Configurar Android

En `android/build.gradle` (nivel proyecto):

```gradle
plugins {
  id 'com.google.gms.google-services' version '4.4.1' apply false
}
```

En `android/app/build.gradle`:

```gradle
plugins {
  id 'com.android.application'
  id 'com.google.gms.google-services'
}
```

### 4. Configurar iOS

- Abre `ios/Runner.xcworkspace` en Xcode.
- Asegúrate de que `GoogleService-Info.plist` esté incluido en el target.
- Habilita **Push Notifications** y **Background Modes → Remote Notifications** en capabilities.
- Sube tu clave APNs en Firebase Console → Project Settings → Cloud Messaging.

### 5. Crear tabla dispositivos en Supabase

Ejecuta `docs/supabase/schema-extensions.sql` en el SQL Editor de Supabase.

### 6. Desplegar la Edge Function

```bash
supabase functions new send-push-notification
# Copia el contenido de docs/supabase/edge-functions/send-push-notification.ts
supabase secrets set FCM_SERVICE_ACCOUNT='{"type":"service_account",...}'
supabase secrets set FCM_PROJECT_ID='tu-project-id'
supabase functions deploy send-push-notification
```

> La clave `FCM_SERVICE_ACCOUNT` es el contenido del archivo `serviceAccountKey.json` de Firebase Admin SDK.

### 7. Actualizar el trigger de notificaciones

Reemplaza `<tu-proyecto>` en `docs/supabase/triggers.sql` por el ID de tu proyecto Supabase.
Habilita la extensión `pg_net`:

```sql
CREATE EXTENSION IF NOT EXISTS pg_net;
```

Luego ejecuta la función y el trigger `notify_cita_status_change`.

### 8. Probar

- Corre la app y revisa la consola de debug. Deberías ver:
  - `FCM Token: ...`
  - `FCM token guardado en Supabase...`
- Cambia el estado de una cita.
- El paciente debería recibir una notificación push.

## Notas importantes

- Las notificaciones in-app actuales (`NotificacionesBloc`) siguen funcionando independientemente.
- Si no configuras Firebase, el servicio no crashea; simplemente omite el guardado del token.
- En producción, considera eliminar tokens inválidos de la tabla `dispositivos` cuando FCM responda con error.
