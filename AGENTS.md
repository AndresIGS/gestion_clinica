# Guía para Agentes de Código

Este archivo contiene el contexto que necesitas para trabajar de forma segura y consistente en este proyecto Flutter.

## Proyecto

- **Nombre**: Gestión Clínica (`sistemav2`).
- **Framework**: Flutter 3.12+.
- **Backend**: Supabase (Auth, PostgreSQL, Realtime, Storage).
- **Arquitectura**: Clean Architecture + Feature-Driven + BLoC.
- **Inyección de dependencias**: GetIt (`lib/injection_container.dart`).

## Comandos obligatorios después de cambios

```bash
flutter pub get        # Si cambiaste pubspec.yaml
flutter analyze        # Debe terminar sin issues
flutter test           # Deben pasar todos los tests
```

Si algún test de widget usa Lottie, usa `pump` con duración en lugar de `pumpAndSettle` para evitar timeouts por animaciones infinitas.

## Convenciones de código

- **Archivos**: `snake_case.dart`.
- **Clases**: `PascalCase`.
- **Variables/Métodos**: `camelCase`.
- **Eventos BLoC**: verbo en infinitivo (`CargarCitasEvent`).
- **Estados BLoC**: sustantivo + participio (`CitasListadas`, `CitasLoading`).
- **No uses Provider ni Riverpod** para estado global. Usa `flutter_bloc`.
- **No crees instancias directas** de repositorios en UI o BLoCs. Usa GetIt.

## Estructura de una feature

```text
features/<nombre>/
├── data/
│   ├── datasources/      # Solo comunicación con Supabase
│   └── models/           # Modelos con fromJson/toJson
├── domain/
│   └── repositories/     # Lógica abstracta (interfaz)
└── presentation/
    ├── blocs/            # Event, State, Bloc
    └── pages/            # Pantallas y widgets propios
```

## Cómo agregar una nueva feature

1. Crea la carpeta bajo `lib/features/<nombre>/` siguiendo la estructura anterior.
2. Define el modelo, data source, repository y BLoC.
3. Registra el BLoC y el repository en `lib/injection_container.dart`.
4. Provee el BLoC en `lib/main.dart` si debe estar disponible globalmente, o usa `BlocProvider` en la pantalla que lo inicia.
5. Agrega tests en `test/` reflejando la estructura de `lib/`.
6. Ejecuta `flutter analyze` y `flutter test`.

## Reglas importantes

- **Sin Firebase**: el proyecto no usa Firebase ni FCM. No agregues dependencias de `firebase_*` ni `device_info_plus` a menos que el usuario lo solicite explícitamente.
- **Variables de entorno**: usa `flutter_dotenv`. Los archivos `.env.dev` y `.env.prod` están en `.gitignore` y nunca deben subirse.
- **Navegación**: usa `lib/core/navigation/app_router.dart` para transiciones consistentes (`AppRouter.slide`, `AppRouter.fade`, etc.). Evita `MaterialPageRoute` directo.
- **Errores**: usa `ErrorHandler.map(e)` en los BLoCs para convertir excepciones en mensajes amigables.
- **UI/UX**: reutiliza widgets de `lib/core/widgets/` (`EmptyState`, `SkeletonList`, `FadeInWrapper`).

## Base de datos

Los archivos SQL relevantes están en `docs/supabase/`:

- `triggers.sql`: sincronización de `auth.users` con `public.usuario`, historial de citas.
- `schema-extensions.sql`: campo `adjuntos`, bucket `historiales`, políticas Storage, función RPC `obtener_citas_con_nombres`.

El schema base (tablas) no está en el repositorio. Si necesitas recrearlo, usa el SQL Editor de Supabase o exporta el schema desde la instancia existente.

## Plataformas objetivo

El usuario prioriza:

- Windows (`flutter run -d windows`)
- Web (`flutter run -d chrome`)
- Android Studio / emulador Android

Antes de aceptar cambios que dependan de plugins nativos, verifica que dichos plugins soporten Windows y Web.

## Tests

- Tests unitarios de BLoCs: `test/*_bloc_test.dart`.
- Tests de widgets: `test/presentation/*_screen_test.dart`.
- Mocks compartidos: `test/presentation/mocks.dart` y `test/mocks.dart`.
- Usa `mocktail` + `bloc_test`.
- Recuerda configurar `whenListen` en mocks de BLoCs cuando los proveas mediante `BlocProvider`.

## Checklist antes de finalizar

- [ ] `flutter analyze` sin issues.
- [ ] `flutter test` todos pasan.
- [ ] No se agregaron secrets ni archivos `.env` al control de versiones.
- [ ] La documentación relevante fue actualizada si cambiaste SQL, dependencias o arquitectura.
