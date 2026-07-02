import 'package:flutter_test/flutter_test.dart';
import 'package:sistemav2/features/auth/data/models/usuario_model.dart';
import 'package:sistemav2/features/citas/data/models/cita_model.dart';

void main() {
  group('UsuarioModel', () {
    test('debe crear un modelo desde JSON correctamente', () {
      final json = {
        'id_usuario': '550e8400-e29b-41d4-a716-446655440000',
        'id_rol': 3,
        'nombre_completo': 'Dr. Ana López',
        'correo': 'ana@clinica.com',
        'telefono': '5551234567',
      };

      final usuario = UsuarioModel.fromJson(json);

      expect(usuario.idUsuario, '550e8400-e29b-41d4-a716-446655440000');
      expect(usuario.idRol, 3);
      expect(usuario.nombreCompleto, 'Dr. Ana López');
      expect(usuario.correo, 'ana@clinica.com');
      expect(usuario.telefono, '5551234567');
    });

    test('dos modelos iguales deben ser iguales con Equatable', () {
      const usuario1 = UsuarioModel(
        idUsuario: 'uuid',
        idRol: 4,
        nombreCompleto: 'Paciente Prueba',
        correo: 'paciente@test.com',
      );
      const usuario2 = UsuarioModel(
        idUsuario: 'uuid',
        idRol: 4,
        nombreCompleto: 'Paciente Prueba',
        correo: 'paciente@test.com',
      );

      expect(usuario1, usuario2);
    });
  });

  group('CitaModel', () {
    test('debe crear un modelo desde JSON correctamente', () {
      final json = {
        'id_cita': 1,
        'id_paciente': 'paciente-uuid',
        'id_medico': 'medico-uuid',
        'fecha_hora': '2026-07-02T10:00:00.000',
        'fecha_hora_fin': '2026-07-02T10:30:00.000',
        'estado': 'solicitado',
        'motivo': 'Consulta general',
      };

      final cita = CitaModel.fromJson(json);

      expect(cita.idCita, 1);
      expect(cita.idPaciente, 'paciente-uuid');
      expect(cita.idMedico, 'medico-uuid');
      expect(cita.fechaHora, DateTime(2026, 7, 2, 10, 0));
      expect(cita.fechaHoraFin, DateTime(2026, 7, 2, 10, 30));
      expect(cita.estado, 'solicitado');
      expect(cita.motivo, 'Consulta general');
    });

    test('debe serializar a JSON correctamente', () {
      final fechaHora = DateTime(2026, 7, 2, 10, 0);
      final cita = CitaModel(
        idPaciente: 'paciente-uuid',
        idMedico: 'medico-uuid',
        fechaHora: fechaHora,
        fechaHoraFin: fechaHora.add(const Duration(minutes: 30)),
        estado: 'solicitado',
        motivo: 'Consulta general',
      );

      final json = cita.toJson();

      expect(json['id_paciente'], 'paciente-uuid');
      expect(json['id_medico'], 'medico-uuid');
      expect(json['estado'], 'solicitado');
      expect(json['motivo'], 'Consulta general');
      expect(json.containsKey('id_cita'), isFalse);
    });
  });
}
