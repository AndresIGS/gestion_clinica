import 'package:equatable/equatable.dart';

class HistorialClinicoModel extends Equatable {
  final int? idRegistro;
  final String idPaciente;
  final String idMedico;
  final int? idCita;
  final String diagnostico;
  final String tratamiento;
  final DateTime? fechaCreacion;
  final List<String> adjuntos;

  const HistorialClinicoModel({
    this.idRegistro,
    required this.idPaciente,
    required this.idMedico,
    this.idCita,
    required this.diagnostico,
    required this.tratamiento,
    this.fechaCreacion,
    this.adjuntos = const [],
  });

  factory HistorialClinicoModel.fromJson(Map<String, dynamic> json) {
    return HistorialClinicoModel(
      idRegistro: json['id_registro'] as int?,
      idPaciente: json['id_paciente'] as String,
      idMedico: json['id_medico'] as String,
      idCita: json['id_cita'] as int?,
      diagnostico: json['diagnostico'] as String,
      tratamiento: json['tratamiento'] as String,
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'] as String)
          : null,
      adjuntos: (json['adjuntos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idRegistro != null) 'id_registro': idRegistro,
      'id_paciente': idPaciente,
      'id_medico': idMedico,
      if (idCita != null) 'id_cita': idCita,
      'diagnostico': diagnostico,
      'tratamiento': tratamiento,
      'adjuntos': adjuntos,
    };
  }

  @override
  List<Object?> get props => [
        idRegistro,
        idPaciente,
        idMedico,
        idCita,
        diagnostico,
        tratamiento,
        fechaCreacion,
        adjuntos,
      ];
}
