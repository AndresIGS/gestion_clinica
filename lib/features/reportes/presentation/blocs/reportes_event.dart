import 'package:equatable/equatable.dart';

abstract class ReportesEvent extends Equatable {
  const ReportesEvent();

  @override
  List<Object> get props => [];
}

class CargarEstadisticasEvent extends ReportesEvent {}
