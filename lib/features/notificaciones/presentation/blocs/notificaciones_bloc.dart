import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../citas/domain/repositories/citas_repository.dart';
import 'notificaciones_event.dart';
import 'notificaciones_state.dart';

class NotificacionesBloc extends Bloc<NotificacionesEvent, NotificacionesState> {
  final CitasRepository citasRepository;
  StreamSubscription? _citasSubscription;

  NotificacionesBloc({required this.citasRepository}) : super(NotificacionesInitial()) {
    on<IniciarEscuchaNotificaciones>((event, emit) {
      _citasSubscription?.cancel();
      
      _citasSubscription = citasRepository.escucharCambiosCitas().listen((citas) {
        // En un caso real, el stream de supabase (.stream) emite la lista completa
        // Aquí podríamos comparar con un estado anterior o simplemente dejar que
        // la UI se suscriba y reaccione. Para simplificar, la UI puede escuchar este evento:
        // Nota: Supabase Realtime envía eventos granulares si usamos .onPostgresChanges
        // pero con .stream() envía la lista actualizada.
      });

      // Alternativa: Si usamos el cliente de Supabase directo para Realtime
      // lo ideal es escuchar .onPostgresChanges para recibir notificaciones de updates específicos.
    });

    on<NotificacionRecibida>((event, emit) {
      emit(NuevaNotificacionState(
        mensaje: event.mensaje,
        uniqueId: const Uuid().v4(),
      ));
    });
  }

  @override
  Future<void> close() {
    _citasSubscription?.cancel();
    return super.close();
  }
}
