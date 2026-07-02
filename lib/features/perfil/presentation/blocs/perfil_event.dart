import 'package:equatable/equatable.dart';

abstract class PerfilEvent extends Equatable {
  const PerfilEvent();

  @override
  List<Object?> get props => [];
}

class CargarPerfilEvent extends PerfilEvent {}

class ActualizarPerfilEvent extends PerfilEvent {
  final String nombreCompleto;
  final String telefono;

  const ActualizarPerfilEvent({
    required this.nombreCompleto,
    required this.telefono,
  });

  @override
  List<Object?> get props => [nombreCompleto, telefono];
}
