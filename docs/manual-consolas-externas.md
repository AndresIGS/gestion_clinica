# Manual paso a paso: configuración en consolas externas

Este documento detalla cada clic y comando que debes ejecutar fuera del editor de código para que la app funcione en un entorno real.

---

## 1. Supabase (base de datos, auth, storage, edge functions)

### 1.1 Crear el proyecto

1. Ve a [https://app.supabase.com](https://app.supabase.com) e inicia sesión.
2. Haz clic en **New project**.
3. Selecciona tu organización, escribe un nombre (p. ej. `sistema-clinico`) y una contraseña segura para la base de datos.
4. Espera a que termine el aprovisionamiento (toma uno o dos minutos).
5. En la pantalla principal del proyecto copia:
   - **Project URL** → lo usarás en `SUPABASE_URL`.
   - **anon public** API key → lo usarás en `SUPABASE_ANON_KEY`.

### 1.2 Configurar variables de entorno en Flutter

1. Abre `.env.example` y reemplaza los valores por los de tu proyecto.
2. Guarda el archivo como:
   - `.env.dev` para desarrollo.
   - `.env.prod` para producción.
3. El formato debe quedar así:

```env
SUPABASE_URL=https://<tu-project-ref>.supabase.co
SUPABASE_ANON_KEY=<tu-anon-key>
```

> Estos archivos no deben subirse a Git. El `.gitignore` ya debería ignorarlos.

### 1.3 Ejecutar el schema base

En el proyecto de Supabase:

1. Ve al menú lateral → **SQL Editor**.
2. Crea una **New query**.
3. Pega el SQL del schema base de tu aplicación (tablas `usuario`, `medico`, `paciente`, `cita`, `historial_cita`, `especialidad`, `horario_medico`, `historial_clinico`).
4. Haz clic en **Run**.

Si aún no tienes el schema base documentado, crea primero las tablas desde el editor visual de Supabase (**Database → Tables → New table**) o exporta el schema de tu instancia de desarrollo actual.

### 1.4 Ejecutar extensiones y triggers

Después del schema base, ejecuta en orden:

1. `docs/supabase/triggers.sql`
   - Crea la función `handle_new_user` que inserta en `public.usuario`, `public.medico` y `public.paciente` cuando se registra un usuario en Auth.
   - Crea la función `log_cita_status_change` que guarda el historial de cambios de estado.
   - Crea el trigger `notify_cita_status_change` para llamar a la Edge Function de notificaciones push.
2. `docs/supabase/schema-extensions.sql`
   - Crea la tabla `public.dispositivos` para guardar tokens FCM.
   - Agrega la columna `adjuntos` a `historial_clinico`.
   - Crea instrucciones para el bucket `historiales` de Storage.
   - Crea la función RPC `obtener_citas_con_nombres` para búsquedas.

> Importante: en `docs/supabase/triggers.sql` busca el placeholder `<tu-proyecto>` y reemplázalo por el **Project Reference ID** de Supabase (las letras que aparecen antes de `.supabase.co` en la URL).

### 1.5 Habilitar la extensión pg_net

En el SQL Editor ejecuta:

```sql
CREATE EXTENSION IF NOT EXISTS pg_net;
```

Esto permite que PostgreSQL haga peticiones HTTP desde el trigger hacia la Edge Function.

### 1.6 Configurar Storage para adjuntos

1. Ve a **Storage** en el menú lateral.
2. Haz clic en **New bucket**.
3. Nombre: `historiales`.
4. Marca **Public bucket** si quieres que las imágenes sean accesibles directamente por URL. Si prefieres privacidad, déjalo privado y ajusta las políticas RLS.
5. Crea el bucket.
6. Ve a la pestaña **Policies** del bucket y crea las políticas indicadas en `docs/supabase/schema-extensions.sql`.

### 1.7 Configurar Authentication (opcional pero recomendado)

1. Ve a **Authentication → Providers**.
2. Asegúrate de que **Email** esté habilitado.
3. En **Authentication → URL Configuration** configura:
   - **Site URL**: la URL de tu app en producción o `http://localhost` durante desarrollo.
   - **Redirect URLs**: URLs permitidas para redirecciones después de confirmación de correo.

---

## 2. Firebase (notificaciones push con FCM)

### 2.1 Crear el proyecto

1. Ve a [https://console.firebase.google.com](https://console.firebase.google.com).
2. Haz clic en **Add project**.
3. Puedes vincularlo al proyecto de Google Cloud de Supabase o crear uno nuevo. El nombre no tiene que coincidir con Supabase.
4. Sigue los pasos del asistente hasta llegar al panel principal.

### 2.2 Registrar la app Android

1. En la consola de Firebase, haz clic en el icono de Android (**</>**) para agregar una app.
2. **Android package name**: debe coincidir exactamente con el `applicationId` de tu `android/app/build.gradle` (por ejemplo `com.example.sistemav2`).
3. **App nickname**: un nombre descriptivo.
4. Opcionalmente agrega el SHA-1 de tu certificado de firma.
5. Haz clic en **Register app**.
6. Descarga el archivo `google-services.json`.
7. Colócalo en `android/app/google-services.json`.

### 2.3 Configurar Gradle de Android

1. Abre `android/build.gradle` (nivel proyecto) y verifica que tenga:

```gradle
plugins {
    id 'com.google.gms.google-services' version '4.4.1' apply false
}
```

2. Abre `android/app/build.gradle` y verifica que tenga:

```gradle
plugins {
    id 'com.android.application'
    id 'com.google.gms.google-services'
}
```

3. En el mismo archivo verifica que `applicationId` coincida con el que registraste en Firebase.

### 2.4 Registrar la app iOS (si aplica)

1. En Firebase, haz clic en el icono de iOS para agregar una app.
2. **Apple bundle ID**: debe coincidir con el `PRODUCT_BUNDLE_IDENTIFIER` de tu proyecto iOS.
3. Haz clic en **Register app**.
4. Descarga `GoogleService-Info.plist`.
5. Colócalo en `ios/Runner/GoogleService-Info.plist` usando Xcode (arrastra el archivo al proyecto).
6. En Xcode habilita:
   - **Signing & Capabilities → + Capability → Push Notifications**.
   - **Signing & Capabilities → + Capability → Background Modes** y marca **Remote notifications**.
7. Sube tu clave APNs en Firebase Console → Project Settings → Cloud Messaging → iOS app configuration.

### 2.5 Obtener la cuenta de servicio de Firebase Admin

1. En Firebase Console ve a **Project settings → Service accounts**.
2. Selecciona **Firebase Admin SDK**.
3. Haz clic en **Generate new private key**.
4. Se descargará un archivo `serviceAccountKey.json`.
5. **No subas este archivo a Git**. Lo usarás solo para configurar el secret de Supabase.

---

## 3. Supabase CLI (instalación y despliegue)

### 3.1 Instalar Supabase CLI

**Windows (PowerShell):**

```powershell
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
```

O descarga el binario desde [releases](https://github.com/supabase/cli/releases).

**macOS/Linux:**

```bash
brew install supabase/tap/supabase
```

Verifica la instalación:

```bash
supabase --version
```

### 3.2 Iniciar sesión

```bash
supabase login
```

Se abrirá el navegador para autorizar el CLI.

### 3.3 Desplegar la Edge Function

Desde la raíz del proyecto Flutter:

**Windows:**

```powershell
.\scripts\deploy_edge_function.ps1 -ProjectId "<tu-project-ref>"
```

**Linux/macOS:**

```bash
bash scripts/deploy_edge_function.sh send-push-notification docs/supabase/edge-functions/send-push-notification.ts <tu-project-ref>
```

El script copia el archivo fuente a `supabase/functions/send-push-notification/index.ts` y ejecuta `supabase functions deploy`.

### 3.4 Configurar secrets de la Edge Function

La Edge Function necesita dos variables de entorno:

```bash
supabase secrets set FCM_SERVICE_ACCOUNT='{"type":"service_account",...}' --project-ref <tu-project-ref>
supabase secrets set FCM_PROJECT_ID='<tu-project-id>' --project-ref <tu-project-ref>
```

Para `FCM_SERVICE_ACCOUNT`, abre el archivo `serviceAccountKey.json` descargado en el paso 2.5, copia TODO su contenido y pégalo como un string JSON en una sola línea.

Alternativa en PowerShell:

```powershell
$json = Get-Content -Raw serviceAccountKey.json
supabase secrets set FCM_SERVICE_ACCOUNT="$json" --project-ref <tu-project-ref>
```

> Reemplaza `<tu-project-ref>` por el ID de tu proyecto Supabase y `<tu-project-id>` por el ID de tu proyecto Firebase.

### 3.5 Verificar que la Edge Function esté activa

1. En Supabase Studio ve a **Edge Functions**.
2. Deberías ver `send-push-notification` con estado **Active**.
3. También puedes revisar los logs desde **Edge Functions → send-push-notification → Logs**.

---

## 4. Verificación final

1. Corre el script de verificación local:

   ```powershell
   .\scripts\verify_setup.ps1
   ```

2. Ejecuta la app en modo desarrollo:

   ```bash
   flutter run --dart-define-from-file=.env.dev
   ```

3. Revisa en la consola de debug:
   - `FCM Token: ...`
   - `FCM token guardado en Supabase...`

4. Cambia el estado de una cita en la app.
5. El paciente debería recibir una notificación push.

---

## 5. Solución de problemas comunes

| Síntoma | Posible causa | Solución |
|---------|---------------|----------|
| No llegan notificaciones push | `pg_net` no habilitado | Ejecuta `CREATE EXTENSION IF NOT EXISTS pg_net;` |
| La Edge Function falla | Secret `FCM_SERVICE_ACCOUNT` mal formado | Verifica que sea JSON válido en una sola línea |
| `google-services.json` no encontrado | No se copió en la ruta correcta | Colócalo en `android/app/google-services.json` |
| Error 401 al llamar FCM | Cuenta de servicio incorrecta | Genera una nueva clave desde Firebase Console |
| Las imágenes no se suben | Bucket `historiales` no existe | Crea el bucket en Supabase Storage |
| Búsqueda de citas no funciona | Función RPC no creada | Ejecuta `docs/supabase/schema-extensions.sql` |

---

## Archivos que debes tener al final

```textnsistema-clinico/
├── android/app/google-services.json          # Descargado de Firebase
├── ios/Runner/GoogleService-Info.plist       # Descargado de Firebase (iOS)
├── .env.dev                                  # Variables de desarrollo
├── .env.prod                                 # Variables de producción
├── docs/supabase/triggers.sql                # Ejecutado en SQL Editor
├── docs/supabase/schema-extensions.sql       # Ejecutado en SQL Editor
└── supabase/functions/send-push-notification/index.ts  # Desplegado vía CLI
```
