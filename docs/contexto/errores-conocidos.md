# Errores Conocidos y Gotchas

## 1. Sincronización de Usuarios en Supabase
- **Gotcha**: No crees registros manualmente en la tabla `public.usuario` desde la aplicación de Flutter. 
- **Razón**: Existe un Trigger de PostgreSQL llamado `on_auth_user_created` que clona el usuario a `public.usuario` automáticamente tras un `Supabase.instance.client.auth.signUp()`. Si insertas desde Flutter crearás choques de primary keys o UUIDs desvinculados del sistema de autenticación.

## 2. Inyección de Dependencias
- **Error Común**: Error en runtime de "No registered type found".
- **Solución**: Asegúrate de que, al crear un nuevo Repository o BLoC, hayas agregado la instrucción `sl.registerFactory` o `sl.registerLazySingleton` en `lib/injection_container.dart`, y hayas ejecutado el hot-restart (la inyección sucede en `main()`).

## 3. Row Level Security (RLS) Invisible
- **Gotcha**: Al probar consultas en la app, la base de datos devuelve listas vacías y no lanza errores.
- **Razón**: Las políticas RLS están activas en Supabase. Si pruebas con un usuario "Paciente", automáticamente la base de datos omite cualquier `Cita` que no le pertenezca gracias a `auth.uid() = id_paciente`. No intentes filtrar a la fuerza en Flutter; confía en el RLS, pero asegúrate de loguearte con el usuario correcto.

## 4. Supabase Stream (Notificaciones In-App)
- **Gotcha**: El método `.stream()` de Supabase puede consumir más memoria de la esperada o devolver la lista entera al hacer un cambio.
- **Razón**: Para una solución de notificaciones granulares (saber exactamente QUÉ fila cambió), deberíamos usar `.onPostgresChanges` (Realtime). Actualmente usamos `.stream()` como workaround temporal.

## 5. Pruebas Unitarias / Widgets
- **Gotcha**: Las pruebas actuales pueden fallar.
- **Razón**: [PENDIENTE: Los tests existentes en `test/` (e.g. `widget_test.dart`) son los genéricos de Flutter y no contemplan la inyección de dependencias `GetIt` ni el `MultiBlocProvider`. Hay que actualizar estos tests o fallarán inmediatamente].
