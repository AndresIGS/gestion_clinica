import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Servicio para gestionar archivos en Supabase Storage.
///
/// Requiere que exista el bucket `historiales` en Supabase con las
/// políticas de acceso adecuadas.
class StorageService {
  StorageService._();

  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _bucket = 'historiales';
  static const Uuid _uuid = Uuid();

  /// Abre la galería y devuelve el archivo seleccionado.
  static Future<XFile?> seleccionarImagen() async {
    final picker = ImagePicker();
    return await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
  }

  /// Sube un archivo al bucket de historiales y devuelve la URL pública.
  static Future<String?> subirAdjuntoHistorial({
    required XFile archivo,
    required String idPaciente,
  }) async {
    try {
      final extension = archivo.name.split('.').last;
      final nombre = '${_uuid.v4()}.$extension';
      final ruta = '$idPaciente/$nombre';

      final bytes = await archivo.readAsBytes();

      await _supabase.storage.from(_bucket).uploadBinary(
            ruta,
            bytes,
            fileOptions: const FileOptions(upsert: false),
          );

      final url = _supabase.storage.from(_bucket).getPublicUrl(ruta);
      return url;
    } catch (e) {
      debugPrint('Error al subir adjunto: $e');
      return null;
    }
  }

  /// Elimina un archivo del bucket dado su URL pública.
  static Future<void> eliminarAdjunto(String url) async {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf(_bucket);
      if (bucketIndex == -1 || bucketIndex + 1 >= pathSegments.length) return;

      final ruta = pathSegments.sublist(bucketIndex + 1).join('/');
      await _supabase.storage.from(_bucket).remove([ruta]);
    } catch (e) {
      debugPrint('Error al eliminar adjunto: $e');
    }
  }
}
