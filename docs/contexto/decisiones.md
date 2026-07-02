# Decisiones Técnicas

Este documento refleja las decisiones arquitectónicas importantes del proyecto y su razonamiento.

## 1. Supabase como BaaS
- **Decisión**: Usar Supabase en lugar de Firebase o un backend personalizado.
- **Por qué**: Necesidad de bases de datos relacionales (PostgreSQL) para manejar entidades interconectadas (Citas, Pacientes, Médicos, Especialidades) y facilidad de uso de Row Level Security (RLS).
- **Descartado**: Firebase Firestore (dificultad con modelos relacionales complejos sin duplicación masiva).

## 2. Separación Auth.Users / Public.Usuario
- **Decisión**: Sincronizar el esquema `auth.users` de Supabase con `public.usuario` mediante un **Trigger SQL**.
- **Por qué**: Las políticas RLS dependen de `auth.uid()`, por lo que el UUID de autenticación debe ser el mismo que la llave primaria de la tabla pública de usuarios.
- **Descartado**: Generar UUIDs en Flutter e insertarlos manualmente. (Generaba inconsistencias donde el usuario autenticado no coincidía con el de la tabla relacional).

## 3. Manejo de Estado con BLoC
- **Decisión**: Usar BLoC en conjunto con Clean Architecture.
- **Por qué**: Asegura un flujo de datos unidireccional y predecible. Facilita la inyección de repositorios y es altamente escalable.
- **Descartado**: Provider/GetX. (Provider puede quedarse corto en lógica de negocio compleja, GetX rompe los límites arquitectónicos al mezclar navegación y estado).

## 4. Trazabilidad de Citas (Trigger SQL)
- **Decisión**: Insertar automáticamente el historial de estados de las citas mediante la base de datos (Trigger).
- **Por qué**: Garantiza integridad absoluta de la data, asegurando que cualquier cambio de estado genere un log, sin depender de que Flutter haga dos llamadas a la API.
