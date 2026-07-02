import 'package:equatable/equatable.dart';

abstract class HistorialEvent extends Equatable {
  const HistorialEvent();

  @override
  List<Object?> get props => [];
}

class CargarHistorialEvent extends HistorialEvent {}
