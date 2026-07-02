import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/error_handler.dart';
import '../../domain/repositories/historial_repository.dart';
import 'historial_event.dart';
import 'historial_state.dart';

class HistorialBloc extends Bloc<HistorialEvent, HistorialState> {
  final HistorialRepository repository;

  HistorialBloc({required this.repository}) : super(HistorialInitial()) {
    on<CargarHistorialEvent>((event, emit) async {
      emit(HistorialLoading());
      try {
        final historial = await repository.obtenerHistorial();
        emit(HistorialLoaded(historial: historial));
      } catch (e) {
        emit(HistorialError(mensaje: ErrorHandler.map(e).message));
      }
    });
  }
}
