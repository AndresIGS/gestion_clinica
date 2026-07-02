# Arquitectura del Sistema

## Stack Tecnológico
- **Frontend**: Flutter (v3.12+) con Material Design 3.
- **Backend / BaaS**: Supabase (PostgreSQL, Auth, Realtime).
- **Gestión del Estado**: BLoC (Business Logic Component).
- **Inyección de Dependencias**: GetIt.

## Mapa de Carpetas (Clean Architecture + Feature-Driven)
El proyecto se organiza principalmente por funcionalidades (`features`), aplicando Clean Architecture en cada una:

```text
lib/
├── core/                   # Constantes, temas, utilidades globales.
├── features/
│   ├── auth/               # Autenticación, Login, Roles.
│   ├── citas/              # Agendamiento, listado y gestión de estados de citas.
│   ├── notificaciones/     # Escucha en tiempo real de cambios en Supabase.
│   └── reportes/           # Estadísticas de citas para administradores.
│       ├── data/           # Modelos y DataSources (comunicación con Supabase).
│       ├── domain/         # Repositorios y Use Cases (lógica abstracta).
│       └── presentation/   # BLoCs, UI, Widgets.
├── injection_container.dart # Configuración de dependencias (GetIt).
└── main.dart               # Punto de entrada y MultiBlocProvider.
```

## Flujo de Datos
1. **UI**: Lanza un `Event` al BLoC.
2. **BLoC**: Llama a un método del `Repository` (Capa de Dominio).
3. **Repository**: Ejecuta el método del `RemoteDataSource` (Capa de Datos).
4. **RemoteDataSource**: Realiza la petición a **Supabase** (RPC, Select, Insert o Auth).
5. Retorno: El DataSource devuelve el modelo, el Repository lo pasa al BLoC, y el BLoC emite un nuevo `State` para reconstruir la UI.

## Qué NO existe en este proyecto
- **Servidor Backend Intermedio**: No hay APIs REST propias ni NodeJS/Python; la comunicación es directa entre la app Flutter y Supabase.
- **Notificaciones Push Nativas**: Actualmente, las notificaciones (`NotificacionesBloc`) son "In-App" y dependen de streams de Supabase Realtime, no de Firebase Cloud Messaging (APNs/FCM).
- **Tests Automatizados Complejos**: La capa de pruebas unitarias/widgets (en `test/`) está en un estado básico / pendiente de expansión.
