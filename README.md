# Gestión Clínica

Aplicación Flutter para la gestión de citas médicas, historial clínico, horarios de médicos y reportes. Diseñada para clínicas pequeñas y medianas con roles de administrador, secretaria, médico y paciente.

## Stack tecnológico

- **Frontend**: Flutter 3.12+ con Material Design 3.
- **Backend / BaaS**: Supabase (PostgreSQL, Auth, Realtime, Storage).
- **Gestión de estado**: BLoC con `flutter_bloc`.
- **Inyección de dependencias**: GetIt.
- **Gráficos**: `fl_chart`.
- **Animaciones**: `lottie`.

## Plataformas soportadas

- ✅ Android (incluyendo emulador de Android Studio)
- ✅ Windows
- ✅ Web (Chrome/Edge)

> Nota: las notificaciones push nativas no están implementadas. Las notificaciones internas funcionan vía Supabase Realtime.

## Requisitos previos

- Flutter SDK 3.12 o superior.
- Un proyecto en [Supabase](https://app.supabase.com).
- PowerShell (solo si usas `scripts/verify_setup.ps1` en Windows).

## Configuración inicial

### 1. Clonar o preparar el proyecto

```bash
flutter pub get
```

### 2. Configurar variables de entorno

Copia `.env.example` a `.env.dev` y `.env.prod`, y reemplaza los valores por los de tu proyecto de Supabase:

```env
SUPABASE_URL=https://<tu-project-ref>.supabase.co
SUPABASE_ANON_KEY=<tu-anon-key>
```

### 3. Configurar Supabase

1. Crea el schema base en el SQL Editor de Supabase (tablas `usuario`, `medico`, `paciente`, `cita`, `historial_cita`, `especialidad`, `horario_medico`, `historial_clinico`).
2. Ejecuta `docs/supabase/triggers.sql`.
3. Ejecuta `docs/supabase/schema-extensions.sql`.
4. Crea el bucket `historiales` en **Storage** (público) o verifica que el SQL lo haya creado.

### 4. Verificar configuración (Windows)

```powershell
.\scripts\verify_setup.ps1
```

## Ejecutar la app

### Desarrollo

```bash
# Android
flutter run --dart-define-from-file=.env.dev

# Windows
flutter run -d windows --dart-define-from-file=.env.dev

# Web
flutter run -d chrome --dart-define-from-file=.env.dev
```

### Producción

```bash
flutter build apk --release --dart-define-from-file=.env.prod
flutter build windows --release --dart-define-from-file=.env.prod
flutter build web --release --dart-define-from-file=.env.prod
```

## Ejecutar tests

```bash
flutter analyze
flutter test
```

## Estructura del proyecto

```text
lib/
├── core/                   # Errores, navegación, servicios, tema, widgets
├── features/               # Módulos por funcionalidad
│   ├── auth/
│   ├── citas/
│   ├── historial/
│   ├── historial_clinico/
│   ├── horarios_medico/
│   ├── notificaciones/
│   ├── perfil/
│   └── reportes/
├── injection_container.dart
└── main.dart
```

Cada feature sigue Clean Architecture con capas `data`, `domain` y `presentation`.

## Roles de usuario

| Rol | ID | Permisos principales |
|-----|----|----------------------|
| Administrador | 1 | Todo, incluyendo reportes y registro de usuarios |
| Secretaria | 2 | Agendar citas, gestionar horarios, registrar usuarios |
| Médico | 3 | Ver citas, gestionar horarios, historial clínico |
| Paciente | 4 | Agendar citas, ver historial clínico |

## Notas importantes

- La app no requiere Firebase para funcionar.
- Los adjuntos del historial clínico se almacenan en Supabase Storage.
- La búsqueda de citas utiliza una función RPC (`obtener_citas_con_nombres`).
- El schema base de la base de datos no está versionado en este repositorio. Se recomienda mantener un respaldo del schema en `docs/supabase/schema-base.sql`.

## Solución de problemas comunes

| Problema | Solución |
|----------|----------|
| Error `operator does not exist: estado_cita = text` | Vuelve a ejecutar `docs/supabase/schema-extensions.sql`; la función RPC ya tiene el cast corregido. |
| No se suben imágenes | Verifica que el bucket `historiales` exista y que la política `INSERT` permita a médicos subir archivos. |
| No se listan citas | Verifica que la función RPC `obtener_citas_con_nombres` esté creada. |
| Tests con Lottie se quedan esperando | Es normal; los tests usan `pump` con duración en lugar de `pumpAndSettle`. |

## Licencia

Proyecto privado. No publicar en pub.dev.
