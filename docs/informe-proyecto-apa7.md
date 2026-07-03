<div align="center">

**Agenda Electrónica Multiplataforma para la Gestión de Citas Médicas con Trazabilidad de Estados y Enfoque en Calidad de Software**

</div>

## Resumen

El presente trabajo describe el desarrollo de una agenda electrónica multiplataforma orientada a la gestión de citas médicas en centros de salud de pequeña y mediana escala. La solución, denominada *MediApp* dentro del contexto académico y materializada en el proyecto de software *sistemav2*, fue construida con el framework Flutter 3.12+, el backend como servicio Supabase y una arquitectura basada en Clean Architecture, BLoC como patrón de gestión de estado e inyección de dependencias mediante GetIt. El sistema soporta tres roles diferenciados —paciente, secretaria y médico— y permite el ciclo completo de una cita médica con trazabilidad de estados: solicitado, aceptado, realizado y cancelado. Adicionalmente, incluye funcionalidades de historial clínico, gestión de horarios médicos, reportes estadísticos, notificaciones en aplicación y adjuntos en almacenamiento en la nube. El proceso de desarrollo incorporó prácticas de calidad de software representativas de la familia de normas ISO/IEC 25000, incluyendo pruebas unitarias y de widget, análisis estático con `flutter analyze`, manejo estructurado de errores y documentación técnica. Los resultados obtenidos demuestran que es posible construir una solución multiplataforma funcional, escalable y centrada en el usuario, capaz de operar en Windows, Web y Android desde un único código base.

**Palabras clave:** agenda médica electrónica, Flutter, Supabase, arquitectura limpia, calidad de software, BLoC, gestión de citas, trazabilidad de estados.

## Introducción

La digitalización de los procesos administrativos y clínicos constituye uno de los ejes centrales de transformación en el sector salud durante las últimas décadas. No obstante, numerosos centros de atención médica de baja y mediana complejidad —consultorios particulares, clínicas comunitarias y pequeños policlínicos— continúan gestionando sus citas médicas mediante herramientas tradicionales como hojas de cálculo, agendas físicas de papel, cuadernos de registro o mensajería instantánea informal (Organización Mundial de la Salud, 2016). Estos métodos, aunque de bajo costo inicial, generan problemas operativos recurrentes: doble reserva de horarios, pérdida de registros, ausencia de comunicación coordinada entre actores, falta de trazabilidad sobre el estado de una cita y dependencia excesiva de una sola persona o dispositivo (Pressman & Maxim, 2015).

Ante esta problemática, surge la necesidad de diseñar una solución informática que centralice la gestión de citas médicas, permita la coordinación entre pacientes, personal administrativo y médicos, y ofrezca trazabilidad completa sobre el ciclo de vida de cada cita. La presente investigación-formativa responde a esa necesidad mediante el desarrollo de una agenda electrónica multiplataforma que utiliza frameworks modernos, aplica patrones de diseño reconocidos, prioriza la usabilidad e incorpora estándares de calidad de software.

El documento está organizado de la siguiente manera: primero se presenta el planteamiento del problema y la justificación del proyecto; luego, los objetivos general y específicos; posteriormente, el marco teórico que sustenta las decisiones técnicas; seguidamente, la metodología y el desarrollo del sistema; finalmente, las pruebas de calidad, los resultados obtenidos, las conclusiones y las referencias bibliográficas.

## Planteamiento del Problema

La gestión ineficiente de citas médicas en entornos de salud de pequeña escala produce consecuencias directas sobre la calidad del servicio y la satisfacción del usuario. La tabla 1 resume las principales problemáticas identificadas y sus consecuencias.

| Problema | Consecuencia |
|----------|--------------|
| Doble reserva de horarios | Pacientes que llegan y no pueden ser atendidos, generando pérdida de confianza en el centro de salud. |
| Pérdida o deterioro de registros físicos | Información clínica y de contacto que resulta irrecuperable, afectando la continuidad de la atención. |
| Falta de comunicación entre secretaria, médico y paciente | Citas olvidadas, horarios desocupados sin aprovechar y desinformación entre los actores. |
| Ausencia de trazabilidad de estados | Imposibilidad de conocer si una cita está solicitada, aceptada, realizada o cancelada. |
| Dependencia de un solo dispositivo o persona | Si la secretaria falta, nadie puede gestionar las citas, paralizando parcialmente la operación. |
| Mala experiencia del usuario | Pacientes insatisfechos, quejas frecuentes y eventual abandono del centro médico. |

La pregunta que orienta este proyecto es: ¿cómo reducir la pérdida de tiempo y los retrasos en la entrega de soluciones informáticas al cliente, específicamente en la gestión de citas médicas, mediante el desarrollo de una agenda electrónica multiplataforma que utilice frameworks modernos, aplique patrones de diseño, priorice la usabilidad y cumpla con estándares de calidad de software?

## Justificación del Proyecto

### Justificación Académica

El proyecto permite integrar las competencias propias de una asignatura orientada al desarrollo de software multiplataforma y calidad de sistemas. En primer lugar, se emplea Flutter como framework para generar aplicaciones Web, móvil y de escritorio desde un único código base, lo cual evidencia el dominio de tecnologías multiplataforma actuales. En segundo lugar, se aplican patrones de diseño y arquitectónicos tales como BLoC (Business Logic Component), Singleton, Factory e Observer, consolidando el conocimiento sobre diseño orientado a objetos y separación de responsabilidades. En tercer lugar, las interfaces de usuario se diseñan bajo principios de usabilidad y Material Design, generando experiencias centradas en el usuario. Finalmente, se incorporan criterios de calidad inspirados en la familia de normas ISO/IEC 25000, expresados mediante pruebas automatizadas, análisis estático y manejo estructurado de errores.

### Justificación Social

La agenda electrónica desarrollada mejora la experiencia de atención médica para pacientes de todas las edades, al proporcionar claridad sobre el estado de sus citas y reducir tiempos de espera innecesarios. Asimismo, disminuye la carga operativa del personal administrativo y sanitario, liberando tiempo que puede destinarse a la atención directa. Desde una perspectiva ambiental, el sistema reduce el uso de papel y registros físicos, contribuyendo a la sostenibilidad de los procesos. Asimismo, facilita el acceso a la salud mediante una tecnología accesible desde dispositivos comunes.

### Justificación Tecnológica

El proyecto demuestra el uso de tecnologías emergentes como frameworks multiplataforma, bases de datos en la nube, sincronización en tiempo real y almacenamiento de archivos. La elección de Supabase como backend permite contar con autenticación, base de datos relacional PostgreSQL, realtime y storage sin necesidad de mantener infraestructura propia. Esta base tecnológica es escalable y permite extender el sistema con futuros módulos como historial clínico completo, recetas electrónicas, telemedicina y reportes avanzados.

## Objetivos del Proyecto Formativo

### Objetivo General

Desarrollar una agenda electrónica multiplataforma para la gestión de citas médicas, que permita a los pacientes solicitar citas y al personal administrativo y sanitario gestionarlas mediante estados (solicitado, aceptado, realizado y cancelado), aplicando frameworks modernos, patrones de diseño, principios de usabilidad y estándares de calidad de software.

### Objetivos Específicos

1. Implementar una solución multiplataforma para Web, móvil y escritorio utilizando el framework Flutter, accediendo a datos mediante Supabase.
2. Diseñar e implementar interfaces de usuario centradas en el paciente y el médico, siguiendo estándares de usabilidad y Material Design.
3. Aplicar patrones de diseño y arquitectónicos, incluyendo BLoC, Singleton, Factory y Observer, en la estructura del software.
4. Incorporar criterios de calidad de sistemas basados en ISO/IEC 25000 a lo largo del ciclo de desarrollo, mediante pruebas unitarias, análisis estático y manejo de errores.
5. Documentar el proceso de desarrollo, incluyendo justificación técnica, manuales, pruebas y recomendaciones de despliegue.

## Marco Teórico

### Frameworks multiplataforma

Los frameworks multiplataforma permiten desarrollar aplicaciones que funcionan en múltiples sistemas operativos a partir de un único código base. Flutter, desarrollado por Google, utiliza el lenguaje Dart y un motor de renderizado propio que dibuja cada píxel en la pantalla, lo que garantiza consistencia visual entre plataformas (Google, 2024). Su arquitectura basada en widgets facilita la composición de interfaces complejas y su compilación nativa permite obtener rendimiento cercano al de aplicaciones desarrolladas de forma nativa.

### Arquitectura de software

La Clean Architecture propuesta por Robert C. Martin (2017) promueve la separación de responsabilidades en capas concéntricas, donde las reglas de negocio son independientes de frameworks, interfaces de usuario y bases de datos. Esta arquitectura mejora la testabilidad, el mantenimiento y la capacidad de adaptación del sistema ante cambios tecnológicos. En el proyecto, la estructura por feature organiza cada módulo en capas de datos, dominio y presentación, facilitando la escalabilidad.

### Patrones de diseño

Los patrones de diseño son soluciones reutilizables a problemas recurrentes del diseño orientado a objetos. Gamma et al. (1994) clasifican los patrones en creacionales, estructurales y de comportamiento. En este proyecto se aplican: BLoC como patrón de comportamiento para separar la lógica de negocio de la interfaz; Singleton a través de GetIt para la inyección de dependencias; Factory en la construcción de modelos y estados; y Observer mediante los streams de estado del BLoC.

### Calidad de software e ISO/IEC 25000

La familia de normas ISO/IEC 25000, conocida como SQuaRE (Systems and Software Quality Requirements and Evaluation), define un modelo de calidad para productos de software basado en ocho características: funcionalidad, rendimiento, compatibilidad, usabilidad, fiabilidad, seguridad, mantenibilidad y portabilidad (ISO/IEC, 2014). En el proyecto se atienden estas características mediante pruebas automatizadas (funcionalidad y fiabilidad), diseño responsivo (usabilidad), análisis estático (mantenibilidad) y soporte multiplataforma (portabilidad).

### Bases de datos en la nube y backend como servicio

Supabase es una alternativa de backend como servicio que proporciona autenticación, base de datos PostgreSQL, funciones en tiempo real y almacenamiento de archivos. PostgreSQL, como sistema de gestión de bases de datos relacional, garantiza integridad referencial, transacciones ACID y extensibilidad mediante funciones y triggers (Supabase, 2024). La combinación de Flutter y Supabase permite construir aplicaciones robustas sin requerir un servidor backend propio.

## Metodología

El desarrollo del sistema se realizó mediante un enfoque iterativo e incremental, organizado en ciclos cortos de construcción, prueba y refactorización. En cada iteración se definieron funcionalidades concretas, se implementaron siguiendo la arquitectura establecida, se ejecutaron pruebas y se documentaron los avances. Esta metodología permitió detectar errores tempranamente y adaptar el sistema a medida que surgían nuevos requisitos o limitaciones técnicas.

Las etapas principales fueron:

1. **Análisis de requisitos:** identificación de actores, funcionalidades y reglas de negocio a partir del problema de contexto.
2. **Diseño de la arquitectura:** definición de Clean Architecture + feature-driven + BLoC + inyección de dependencias con GetIt.
3. **Configuración del entorno:** integración de Supabase, gestión de variables de entorno con `flutter_dotenv` y configuración de plataformas objetivo (Windows, Web, Android).
4. **Desarrollo incremental:** construcción de features por orden de prioridad (autenticación, citas, perfiles, historial clínico, reportes, horarios médicos, notificaciones).
5. **Aseguramiento de calidad:** ejecución continua de `flutter analyze` y `flutter test`, manejo de excepciones y documentación de decisiones técnicas.
6. **Documentación:** elaboración de README, guía para agentes de código (AGENTS.md) y scripts SQL de soporte.

## Desarrollo del Sistema

### Repositorio del proyecto

El código fuente del sistema, junto con la documentación técnica, scripts SQL y pruebas automatizadas, se encuentra disponible de manera pública en el repositorio de GitHub gestionado por el autor del proyecto (AndresIGS, 2026). El repositorio permite clonar el proyecto, reproducir el entorno de desarrollo mediante las instrucciones contenidas en el archivo `README.md`, y ejecutar las pruebas de calidad documentadas en este informe. La dirección del repositorio es https://github.com/AndresIGS/gestion_clinica.

### Análisis de requisitos

El sistema contempla tres roles principales con permisos diferenciados:

- **Paciente:** puede registrarse, iniciar sesión, solicitar citas con médicos disponibles, visualizar el estado de sus citas y consultar su historial clínico.
- **Secretaria/Administrador:** gestiona citas de todos los usuarios, actualiza estados, registra usuarios con roles de médico o secretaria, y accede a reportes.
- **Médico:** consulta sus citas asignadas, registra diagnósticos y tratamientos en el historial clínico, gestiona su horario de atención y adjunta archivos a las consultas.

El flujo principal de una cita médica sigue el ciclo de estados: *solicitado → aceptado → realizado*, con la posibilidad de transitar a *cancelado* desde cualquier estado previo. Cada cambio de estado se registra en el historial de cambios para garantizar trazabilidad.

### Diseño de la arquitectura

El proyecto adopta una arquitectura limpia organizada por features. Cada feature contiene tres capas:

- **Data:** fuentes de datos remotas (Supabase), modelos con métodos `fromJson`/`toJson` y repositorios de implementación.
- **Domain:** contratos de repositorios y, cuando aplica, entidades de negocio.
- **Presentation:** BLoCs, eventos, estados, pantallas y widgets específicos.

La comunicación entre capas se realiza mediante repositorios inyectados con GetIt, garantizando bajo acoplamiento y alta testabilidad. La navegación se centraliza en `AppRouter`, que proporciona transiciones consistentes entre pantallas.

### Implementación tecnológica

El sistema fue desarrollado con Flutter 3.12+ y el lenguaje Dart. Las dependencias principales incluyen:

- `supabase_flutter` para autenticación, base de datos y almacenamiento.
- `flutter_bloc` para la gestión de estado mediante el patrón BLoC.
- `get_it` para inyección de dependencias.
- `flutter_dotenv` para la gestión de variables de entorno.
- `intl` para formateo de fechas y horas.
- `fl_chart` para visualización de reportes estadísticos.
- `image_picker` para la selección de adjuntos en el historial clínico.

El backend se implementó en Supabase, utilizando PostgreSQL como base de datos relacional, triggers para sincronizar usuarios de autenticación con la tabla `public.usuario`, funciones RPC para consultas complejas como `obtener_citas_con_nombres`, y políticas de seguridad a nivel de filas (RLS) para controlar el acceso a los datos.

### Funcionalidades desarrolladas

El sistema incluye las siguientes funcionalidades implementadas y verificadas:

- **Autenticación y roles:** registro con restricción de rol público a paciente, registro de médicos y secretarias por parte del administrador, inicio de sesión, splash screen con verificación de sesión activa.
- **Gestión de citas médicas:** solicitud de citas, validación contra horarios del médico, verificación de solapamientos, listado con paginación, filtros por estado y fecha, búsqueda textual, cambio de estados con trazabilidad.
- **Historial clínico:** registro de diagnóstico y tratamiento por cita, adjuntos de imágenes almacenados en Supabase Storage, visualización del historial por paciente.
- **Horarios médicos:** configuración de días y horas de atención por parte del médico, utilizados para validar la disponibilidad al momento de agendar.
- **Perfil de usuario:** visualización y edición de datos personales según el rol.
- **Reportes:** estadísticas de citas con filtros por fecha y médico, visualización mediante gráficos de barras.
- **Notificaciones:** bandeja de notificaciones internas generadas ante cambios relevantes en las citas.

## Pruebas y Calidad de Software

El aseguramiento de calidad se abordó desde múltiples dimensiones alineadas con ISO/IEC 25000:

- **Funcionalidad:** se verificó que cada feature cumpliera con los requisitos mediante pruebas unitarias de modelos y BLoCs, así como pruebas de widget para las pantallas principales.
- **Fiabilidad:** se implementó un manejador de errores centralizado (`ErrorHandler`) que convierte excepciones en mensajes comprensibles para el usuario y evita fallos inesperados.
- **Usabilidad:** se diseñaron interfaces con Material Design 3, estados vacíos, esqueletos de carga (`SkeletonList`), animaciones suaves (`FadeInWrapper`) y mensajes de error amigables.
- **Mantenibilidad:** el análisis estático con `flutter analyze` se ejecutó de forma continua, manteniendo el proyecto libre de advertencias. La arquitectura por capas facilita futuras modificaciones.
- **Portabilidad:** el sistema se configuró para ejecutarse en Windows, Web (Chrome) y Android, validando la compatibilidad multiplataforma de Flutter.

Al finalizar el desarrollo, el proyecto alcanzó los siguientes indicadores de calidad:

- `flutter analyze`: sin issues detectadas.
- `flutter test`: 24 pruebas automatizadas aprobadas.
- Cobertura de pruebas en modelos, BLoCs y pantallas principales (`LoginScreen`, `DashboardScreen`, `ListadoCitasScreen`, `ReportesScreen`).

## Resultados

El resultado del proyecto es una aplicación funcional que permite gestionar citas médicas de manera centralizada y multiplataforma. El sistema resuelve las problemáticas identificadas en el planteamiento del problema de la siguiente manera:

- **Doble reserva:** se elimina mediante validación de disponibilidad del médico y verificación de solapamientos en la base de datos.
- **Pérdida de registros:** la información se almacena de forma persistente en PostgreSQL con respaldo en la nube.
- **Falta de comunicación:** los estados de las citas son visibles para todos los roles en tiempo real.
- **Ausencia de trazabilidad:** cada cita cuenta con un estado controlado y un historial de cambios.
- **Dependencia de una sola persona:** cualquier usuario autorizado puede gestionar las citas desde cualquier dispositivo con acceso a Internet.
- **Mala experiencia del usuario:** la interfaz fue diseñada con enfoque en usabilidad, retroalimentación clara y tiempos de respuesta reducidos.

## Conclusiones

El desarrollo de la agenda electrónica multiplataforma permitió demostrar la viabilidad de construir soluciones de salud accesibles, escalables y centradas en el usuario mediante tecnologías modernas. La combinación de Flutter y Supabase resultó adecuada para el alcance del proyecto, pues permitió desarrollar para múltiples plataformas desde un único código base y contar con un backend robusto sin necesidad de infraestructura propia.

La aplicación de Clean Architecture, BLoC e inyección de dependencias contribuyó a obtener un código modular, testable y mantenible. Las prácticas de calidad de software incorporadas, especialmente las pruebas automatizadas y el análisis estático, aseguraron la estabilidad del sistema a lo largo del desarrollo iterativo.

Como trabajo futuro, el sistema puede extenderse con módulos de recetas electrónicas, telemedicina, recordatorios automatizados por correo electrónico, integración con calendarios externos y reportes analíticos avanzados para la toma de decisiones en los centros de salud.

## Referencias

AndresIGS. (2026). *sistemav2* [Código fuente]. GitHub. https://github.com/AndresIGS/gestion_clinica

Gamma, E., Helm, R., Johnson, R., & Vlissides, J. (1994). *Design patterns: Elements of reusable object-oriented software*. Addison-Wesley.

Google. (2024). *Flutter documentation*. https://docs.flutter.dev/

Google. (2024). *Material Design 3*. https://m3.material.io/

ISO/IEC. (2014). *ISO/IEC 25000:2014 Systems and software engineering — Systems and software Quality Requirements and Evaluation (SQuaRE) — Guide to SQuaRE*. International Organization for Standardization.

Martin, R. C. (2017). *Clean architecture: A craftsman's guide to software structure and design*. Prentice Hall.

Organización Mundial de la Salud. (2016). *Global diffusion of eHealth: Making universal health coverage achievable*. World Health Organization. https://www.who.int/publications/i/item/global-diffusion-of-ehealth

Pressman, R. S., & Maxim, B. R. (2015). *Software engineering: A practitioner's approach* (8th ed.). McGraw-Hill Education.

Supabase. (2024). *Supabase documentation*. https://supabase.com/docs
