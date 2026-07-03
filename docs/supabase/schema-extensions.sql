-- Extensiones del schema para funcionalidades adicionales
-- ============================================================
-- Ejecuta este archivo en el SQL Editor de Supabase después de
-- haber creado el schema base de la aplicación.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Columna fecha_hora_fin en cita
-- ------------------------------------------------------------
-- La app asigna una duracion de 30 minutos a cada cita y valida
-- solapamientos usando este campo. Si tu schema base no lo incluye,
-- agregalo aqui.
-- ------------------------------------------------------------
ALTER TABLE public.cita
ADD COLUMN IF NOT EXISTS fecha_hora_fin timestamp with time zone;

-- ------------------------------------------------------------
-- 2. Campo adjuntos en historial_clinico
-- ------------------------------------------------------------
-- Permite guardar URLs de archivos subidos a Supabase Storage.
-- ------------------------------------------------------------
ALTER TABLE public.historial_clinico
ADD COLUMN IF NOT EXISTS adjuntos text [] DEFAULT '{}'::text [];
-- ------------------------------------------------------------
-- 3. Bucket de Supabase Storage: historiales
-- ------------------------------------------------------------
-- Crea el bucket si no existe. Ajusta 'public' según tu modelo de
-- seguridad (true = accesible por URL, false = solo mediante RLS).
-- ------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public)
VALUES ('historiales', 'historiales', true) ON CONFLICT (id) DO NOTHING;
-- ------------------------------------------------------------
-- Políticas de acceso recomendadas para el bucket historiales.
-- Ajusta según tus necesidades de seguridad.
-- ------------------------------------------------------------
-- Eliminamos las políticas previas si existen para poder recrearlas.
DROP POLICY IF EXISTS "Usuarios autenticados pueden leer historiales" ON storage.objects;
DROP POLICY IF EXISTS "Médicos pueden subir historiales" ON storage.objects;
DROP POLICY IF EXISTS "Médicos pueden eliminar historiales" ON storage.objects;

-- Como el bucket es público, los archivos se acceden directamente por URL.
-- Las URLs se guardan en historial_clinico.adjuntos, por lo que no es
-- necesaria una politica SELECT amplia que exponga todos los archivos.
-- Si en el futuro necesitas listar objetos desde el cliente, crea una
-- politica mas restrictiva, por ejemplo por carpeta de usuario.

CREATE POLICY "Médicos pueden subir historiales"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'historiales'
    AND auth.uid() IN (
      SELECT id_medico FROM public.medico
    )
  );

CREATE POLICY "Médicos pueden eliminar historiales"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'historiales'
    AND auth.uid() IN (
      SELECT id_medico FROM public.medico
    )
  );
-- ------------------------------------------------------------
-- 4. Función RPC: búsqueda de citas con nombres
-- ------------------------------------------------------------
-- Permite buscar citas por nombre de paciente, médico o motivo,
-- respetando los filtros de rol, estado y rango de fechas.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.obtener_citas_con_nombres(
    p_id_usuario uuid,
    p_id_rol int,
    p_estado text DEFAULT NULL,
    p_fecha_inicio timestamp with time zone DEFAULT NULL,
    p_fecha_fin timestamp with time zone DEFAULT NULL,
    p_busqueda text DEFAULT NULL,
    p_limit int DEFAULT 20,
    p_offset int DEFAULT 0
  ) RETURNS TABLE(
    id_cita int,
    id_paciente uuid,
    id_medico uuid,
    fecha_hora timestamp with time zone,
    fecha_hora_fin timestamp with time zone,
    estado text,
    motivo text,
    nombre_paciente text,
    nombre_medico text
  ) LANGUAGE sql SECURITY DEFINER AS $$
SELECT c.id_cita,
  c.id_paciente,
  c.id_medico,
  c.fecha_hora,
  c.fecha_hora_fin,
  c.estado::text,
  c.motivo,
  pu.nombre_completo AS nombre_paciente,
  mu.nombre_completo AS nombre_medico
FROM public.cita c
  JOIN public.paciente p ON p.id_paciente = c.id_paciente
  JOIN public.usuario pu ON pu.id_usuario = p.id_paciente
  JOIN public.medico m ON m.id_medico = c.id_medico
  JOIN public.usuario mu ON mu.id_usuario = m.id_medico
WHERE (
    p_id_rol = 1
    OR p_id_rol = 2
    OR (
      p_id_rol = 3
      AND c.id_medico = p_id_usuario
    )
    OR (
      p_id_rol = 4
      AND c.id_paciente = p_id_usuario
    )
  )
  AND (
    p_estado IS NULL
    OR c.estado = p_estado::estado_cita
  )
  AND (
    p_fecha_inicio IS NULL
    OR c.fecha_hora >= p_fecha_inicio
  )
  AND (
    p_fecha_fin IS NULL
    OR c.fecha_hora <= p_fecha_fin
  )
  AND (
    p_busqueda IS NULL
    OR p_busqueda = ''
    OR pu.nombre_completo ILIKE '%' || p_busqueda || '%'
    OR mu.nombre_completo ILIKE '%' || p_busqueda || '%'
    OR c.motivo ILIKE '%' || p_busqueda || '%'
  )
ORDER BY c.fecha_hora DESC
LIMIT p_limit OFFSET p_offset;
$$;