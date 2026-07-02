import 'package:equatable/equatable.dart';

class UsuarioModel extends Equatable {
  final String idUsuario;
  final int idRol;
  final String nombreCompleto;
  final String correo;
  final String? telefono; // Puede ser nulo según tu BD

  const UsuarioModel({
    required this.idUsuario,
    required this.idRol,
    required this.nombreCompleto,
    required this.correo,
    this.telefono,
  });

  // Aplicación del Patrón Factory para construir el objeto desde Supabase
  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      idUsuario: json['id_usuario'] as String,
      idRol: json['id_rol'] as int,
      nombreCompleto: json['nombre_completo'] as String,
      correo: json['correo'] as String,
      telefono: json['telefono'] as String?,
    );
  }

  // Para enviar datos a la BD si fuera necesario
  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'id_rol': idRol,
      'nombre_completo': nombreCompleto,
      'correo': correo,
      'telefono': telefono,
    };
  }

  // Equatable ayuda a comparar objetos en el BLoC sin errores
  @override
  List<Object?> get props => [
    idUsuario,
    idRol,
    nombreCompleto,
    correo,
    telefono,
  ];
}
