# Checklist de despliegue

Este documento resume todo lo que se debe ejecutar o configurar para llevar la app a un entorno real.

## 1. Variables de entorno

- [ ] `.env.dev` con credenciales de desarrollo de Supabase.
- [ ] `.env.prod` con credenciales de producción de Supabase.
- [ ] Nunca commitear archivos `.env` reales.

## 2. Base de datos Supabase

Ejecutar en orden en el SQL Editor de Supabase. Para instrucciones detalladas paso a paso revisa `docs/manual-consolas-externas.md`.

1. Schema base de la app (tablas `usuario`, `medico`, `paciente`, `cita`, `historial_cita`, `especialidad`, `horario_medico`, `historial_clinico`).
2. `docs/supabase/triggers.sql` — funciones y triggers de sincronización de usuario e historial de citas.
3. `docs/supabase/schema-extensions.sql` — tabla `dispositivos`, campo `adjuntos`, bucket `historiales` y función RPC `obtener_citas_con_nombres`.

## 3. Firebase Cloud Messaging

- [ ] Crear proyecto en [Firebase Console](https://console.firebase.google.com/).
- [ ] Registrar app Android y descargar `google-services.json` → `android/app/`.
- [ ] Registrar app iOS y descargar `GoogleService-Info.plist` → `ios/Runner/`.
- [ ] Configurar plugins en `android/build.gradle` y `android/app/build.gradle`.
- [ ] Habilitar Push Notifications y Background Modes en Xcode.
- [ ] Generar cuenta de servicio y descargar `serviceAccountKey.json`.

## 4. Supabase Edge Function

- [ ] Ejecutar `scripts/deploy_edge_function.ps1` (Windows) o `scripts/deploy_edge_function.sh` (Linux/macOS).
- [ ] Configurar secrets:
  ```bash
  supabase secrets set FCM_SERVICE_ACCOUNT='<contenido de serviceAccountKey.json>'
  supabase secrets set FCM_PROJECT_ID='tu-project-id'
  ```
- [ ] Reemplazar `<tu-proyecto>` en `docs/supabase/triggers.sql` por el ID real del proyecto Supabase.
- [ ] Habilitar extensión `pg_net`:
  ```sql
  CREATE EXTENSION IF NOT EXISTS pg_net;
  ```

## 5. Supabase Storage

- [ ] Crear bucket `historiales` (público o con políticas RLS según necesidad).
- [ ] Aplicar políticas del bucket definidas en `docs/supabase/schema-extensions.sql`.

## 6. Verificación local

```bash
flutter pub get
flutter analyze
flutter test
```

## 7. Verificación de configuración

```powershell
.\scripts\verify_setup.ps1
```

## 8. Build de producción

```bash
flutter build apk --release --dart-define-from-file=.env.prod
flutter build ios --release --dart-define-from-file=.env.prod
```

## Notas

- La app funciona sin FCM configurado, pero no enviará notificaciones push.
- Si cambias el schema base, actualiza también los archivos SQL en `docs/supabase/`.
