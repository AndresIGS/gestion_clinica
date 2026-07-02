import 'package:equatable/equatable.dart';

class HistorialCitaModel extends Equatable {
  final int idHistorial;
  final int idCita;
  final String? idUsuarioAccion;
  final String estadoAnterior;
  final String estadoNuevo;
  final String? comentario;
  final DateTime fechaCambio;
  final DateTime? fechaCita;
  final String? idPaciente;
  final String? idMedico;

  const HistorialCitaModel({
    required this.idHistorial,
    required this.idCita,
    this.idUsuarioAccion,
    required this.estadoAnterior,
    required this.estadoNuevo,
    this.comentario,
    required this.fechaCambio,
    this.fechaCita,
    this.idPaciente,
    this.idMedico,
  });

  factory HistorialCitaModel.fromJson(Map<String, dynamic> json) {
    final citaJson = json['cita'] as Map<String, dynamic>?;

    return HistorialCitaModel(
      idHistorial: json['id_historial'] as int,
      idCita: json['id_cita'] as int,
      idUsuarioAccion: json['id_usuario_accion'] as String?,
      estadoAnterior: json['estado_anterior'] as String,
      estadoNuevo: json['estado_nuevo'] as String,
      comentario: json['comentario'] as String?,
      fechaCambio: DateTime.parse(json['fecha_cambio'] as String),
      fechaCita: citaJson != null
          ? DateTime.tryParse(citaJson['fecha_hora'] ?? '')
          : null,
      idPaciente: citaJson?['id_paciente'] as String?,
      idMedico: citaJson?['id_medico'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        idHistorial,
        idCita,
        idUsuarioAccion,
        estadoAnterior,
        estadoNuevo,
        comentario,
        fechaCambio,
        fechaCita,
        idPaciente,
        idMedico,
      ];
}
