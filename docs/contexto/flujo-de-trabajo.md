# Flujo de Trabajo (Workflow)

## Pasos para agregar un nuevo "Feature" (Funcionalidad)

1. **Crear estructura base**:
   - Agrega una nueva carpeta bajo `lib/features/nombre_del_feature`.
   - Crea subcarpetas: `data`, `domain`, `presentation`.
2. **Capa de Dominio**:
   - Define las entidades (opcional).
   - Crea la interfaz del repositorio en `domain/repositories/nombre_repository.dart`.
3. **Capa de Datos**:
   - Crea los modelos (ej. `nombre_model.dart`).
   - Implementa el `RemoteDataSource` que interactúe con Supabase.
   - Implementa el Repositorio (heredando de la interfaz del Dominio).
4. **Capa de Presentación**:
   - Crea el BLoC (`Events`, `States`, `Bloc`).
   - Registra el DataSource, Repository y BLoC en `lib/injection_container.dart`.
   - Si es necesario acceso global, expón el BLoC en el `MultiBlocProvider` en `lib/main.dart`.
   - Desarrolla las pantallas (`screens/`) y widgets consumiendo el BLoC a través de `BlocBuilder` o `BlocConsumer`.

## Checklist de "Terminado" (DoD)
- [ ] Compila sin errores ni warnings del linter en `analysis_options.yaml`.
- [ ] No existen dependencias directas de Supabase dentro de las capas UI.
- [ ] [PENDIENTE: Cobertura mínima de Unit Tests superada].
- [ ] La UI cumple con Material Design 3.
- [ ] Archivos de `docs/contexto/` actualizados si aplica un cambio de arquitectura.

## Deploy
- **Android**: `flutter build apk` o `flutter build appbundle`.
- **Web**: `flutter build web`.
- Configurar variables de entorno y anon keys correspondientes al ambiente de Producción en el `Supabase.initialize()` (actualmente en `main.dart`).
