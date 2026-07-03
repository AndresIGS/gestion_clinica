import 'package:equatable/equatable.dart';

class HorarioMedicoModel extends Equatable {
  final int? idHorario;
  final String idMedico;
  final int diaSemana;
  final String horaInicio;
  final String horaFin;
  final bool activo;

  const HorarioMedicoModel({
    this.idHorario,
    required this.idMedico,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    this.activo = true,
  });

  factory HorarioMedicoModel.fromJson(Map<String, dynamic> json) {
    return HorarioMedicoModel(
      idHorario: json['id_horario'] as int?,
      idMedico: json['id_medico'] as String,
      diaSemana: json['dia_semana'] as int,
      horaInicio: json['hora_inicio'] as String,
      horaFin: json['hora_fin'] as String,
      activo: json['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idHorario != null) 'id_horario': idHorario,
      'id_medico': idMedico,
      'dia_semana': diaSemana,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'activo': activo,
    };
  }

  String get nombreDia {
    return switch (diaSemana) {
      1 => 'Lunes',
      2 => 'Martes',
      3 => 'Miércoles',
      4 => 'Jueves',
      5 => 'Viernes',
      6 => 'Sábado',
      7 => 'Domingo',
      _ => 'Desconocido',
    };
  }

  HorarioMedicoModel copyWith({
    int? idHorario,
    String? idMedico,
    int? diaSemana,
    String? horaInicio,
    String? horaFin,
    bool? activo,
  }) {
    return HorarioMedicoModel(
      idHorario: idHorario ?? this.idHorario,
      idMedico: idMedico ?? this.idMedico,
      diaSemana: diaSemana ?? this.diaSemana,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      activo: activo ?? this.activo,
    );
  }

  @override
  List<Object?> get props => [
        idHorario,
        idMedico,
        diaSemana,
        horaInicio,
        horaFin,
        activo,
      ];
}
