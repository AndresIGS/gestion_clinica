import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../citas/data/models/cita_model.dart';
import '../../../citas/domain/repositories/citas_repository.dart';
import 'notificaciones_event.dart';
import 'notificaciones_state.dart';

class NotificacionesBloc extends Bloc<NotificacionesEvent, NotificacionesState> {
  final CitasRepository citasRepository;
  StreamSubscription? _citasSubscription;
  List<CitaModel> _citasAnteriores = [];

  NotificacionesBloc({required this.citasRepository})
      : super(NotificacionesInitial()) {
    on<IniciarEscuchaNotificaciones>((event, emit) {
      _citasSubscription?.cancel();
      _citasAnteriores = [];

      _citasSubscription = citasRepository.escucharCambiosCitas().listen(
        (citas) => _procesarCambios(citas, event.idRol),
        onError: (e) => debugPrint('Error en stream de notificaciones: $e'),
      );
    });

    on<NotificacionRecibida>((event, emit) {
      emit(
        NuevaNotificacionState(
          mensaje: event.mensaje,
          uniqueId: const Uuid().v4(),
        ),
      );
    });
  }

  /// Compara la lista nueva con la anterior y emite notificaciones cuando
  /// detecta cambios reales (nuevas citas o cambios de estado).
  void _procesarCambios(List<CitaModel> citas, int idRol) {
    // La primera emisión solo inicializa el estado, sin alertar.
    if (_citasAnteriores.isEmpty) {
      _citasAnteriores = citas;
      return;
    }

    if (_listasSonIguales(_citasAnteriores, citas)) {
      return;
    }

    // Detectar qué cambió para dar un mensaje más útil.
    final nuevasCitas = citas.where(
      (c) => !_citasAnteriores.any((prev) => prev.idCita == c.idCita),
    );

    String mensaje;
    if (nuevasCitas.isNotEmpty) {
      mensaje = idRol == 4
          ? 'Se ha agendado una nueva cita para ti.'
          : 'Tienes una nueva cita solicitada.';
    } else {
      mensaje = 'Una de tus citas cambió de estado.';
    }

    add(NotificacionRecibida(mensaje: mensaje, cita: citas.first));
    _citasAnteriores = citas;
  }

  bool _listasSonIguales(List<CitaModel> a, List<CitaModel> b) {
    if (a.length != b.length) return false;
    final aOrdenada = [...a]..sort((x, y) => (x.idCita ?? 0).compareTo(y.idCita ?? 0));
    final bOrdenada = [...b]..sort((x, y) => (x.idCita ?? 0).compareTo(y.idCita ?? 0));
    for (var i = 0; i < aOrdenada.length; i++) {
      if (aOrdenada[i] != bOrdenada[i]) return false;
    }
    return true;
  }

  @override
  Future<void> close() {
    _citasSubscription?.cancel();
    return super.close();
  }
}
