import 'package:equatable/equatable.dart';

class CitaModel extends Equatable {
  final int? idCita;
  final String idPaciente;
  final String idMedico;
  final DateTime fechaHora;
  final DateTime fechaHoraFin;
  final String estado;
  final String? motivo;
  final String? nombrePaciente;
  final String? nombreMedico;

  const CitaModel({
    this.idCita,
    required this.idPaciente,
    required this.idMedico,
    required this.fechaHora,
    required this.fechaHoraFin,
    this.estado = 'solicitado', // Estado inicial por defecto
    this.motivo,
    this.nombrePaciente,
    this.nombreMedico,
  });

  // Factory para recibir datos desde Supabase
  factory CitaModel.fromJson(Map<String, dynamic> json) {
    return CitaModel(
      idCita: json['id_cita'] as int?,
      idPaciente: json['id_paciente'] as String,
      idMedico: json['id_medico'] as String,
      fechaHora: DateTime.parse(json['fecha_hora']),
      fechaHoraFin: DateTime.parse(json['fecha_hora_fin']),
      estado: json['estado'] as String,
      motivo: json['motivo'] as String?,
      nombrePaciente: json['nombre_paciente'] as String?,
      nombreMedico: json['nombre_medico'] as String?,
    );
  }

  // Convertir a JSON para insertar en Supabase
  Map<String, dynamic> toJson() {
    return {
      if (idCita != null)
        'id_cita':
            idCita, // Se omite al crear una nueva (Postgres lo autogenera)
      'id_paciente': idPaciente,
      'id_medico': idMedico,
      'fecha_hora': fechaHora.toIso8601String(),
      'fecha_hora_fin': fechaHoraFin.toIso8601String(),
      'estado': estado,
      'motivo': motivo,
    };
  }

  @override
  List<Object?> get props => [
    idCita,
    idPaciente,
    idMedico,
    fechaHora,
    fechaHoraFin,
    estado,
    motivo,
    nombrePaciente,
    nombreMedico,
  ];
}
