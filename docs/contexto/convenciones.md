# Convenciones del Proyecto

## Estilo y Naming
- **Archivos**: `snake_case.dart` (ej. `listado_citas_screen.dart`).
- **Clases**: `PascalCase` (ej. `ListadoCitasScreen`).
- **Variables/Métodos**: `camelCase` (ej. `obtenerCitas()`).
- **Constantes**: `camelCase` o `SCREAMING_SNAKE_CASE` (ej. `coloresPrimarios`).

## Patrones y Arquitectura
- **Clean Architecture**: Obligatoria separación en `data`, `domain`, `presentation`. No mezclar lógica de Supabase en la UI.
- **BLoC**: Usado estrictamente para el manejo del estado.
  - Eventos: Nombrados como verbo en infinitivo o participio (ej. `CargarCitasEvent`).
  - Estados: Nombrados como sustantivo + participio (ej. `CitasListadas`, `CitasLoading`).
- **Inyección de Dependencias**: Usar `GetIt` (en `injection_container.dart`). **Prohibido** crear instancias directas (`Repository repo = RepositoryImpl();`) dentro de los BLoCs o UI.

## Patrones Prohibidos
- **SetState intensivo**: Se permite `setState` solo para formularios locales (ej. campos de texto), pero la lógica de negocio debe ir en el BLoC.
- **Provider / Riverpod**: La gestión global del estado es con `flutter_bloc`. No introducir otros gestores.

## Commits
- Usamos **Conventional Commits**:
  - `feat: [descripción]` para nuevas funcionalidades.
  - `fix: [descripción]` para correcciones de errores.
  - `docs: [descripción]` para cambios en la documentación.

## Tests
- Ubicados en `/test`, reflejando la estructura de `/lib`.
- [PENDIENTE: Definir convención estricta de tests unitarios cuando se implemente una suite completa].
