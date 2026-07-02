# Glosario del Sistema

## Entidades Principales

- **Usuario**: Cualquier persona que utiliza el sistema. Registrado tanto en la autenticación (Supabase `auth.users`) como en la tabla relacional (`public.usuario`).
- **Rol**: Nivel de acceso del usuario. Define permisos en UI y base de datos.
  - `1`: Administrador.
  - `2`: Secretaria.
  - `3`: Médico.
  - `4`: Paciente.
- **Paciente**: Sub-entidad (o rol `4`) del usuario que puede agendar citas.
- **Médico**: Sub-entidad (o rol `3`) del usuario, con especialidades asociadas, con quien se agendan las citas.
- **Cita**: Encuentro programado entre un Paciente y un Médico.

## Estados de una Cita
- **solicitado**: El paciente pidió la cita pero aún no está confirmada.
- **aceptado**: La secretaria o el médico confirmaron la cita.
- **realizado**: El médico atendió la cita y la finalizó.
- **cancelado**: Cualquiera de las partes canceló la cita antes de su realización.

## Siglas Internas
- **BLoC**: Business Logic Component. Patrón arquitectónico de manejo de estados basado en Streams.
- **RLS**: Row Level Security. Políticas de seguridad en PostgreSQL/Supabase que limitan qué filas puede leer o modificar un usuario.
- **BaaS**: Backend as a Service (refiriéndose a Supabase).
- **DI / GetIt**: Inyección de Dependencias (Dependency Injection), librerías que proveen instancias globales controladas.
