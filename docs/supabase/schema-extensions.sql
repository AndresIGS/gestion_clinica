-- Extensiones del schema para funcionalidades adicionales
-- ============================================================
-- Ejecuta este archivo en el SQL Editor de Supabase después de
-- haber creado el schema base de la aplicación.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Tabla: dispositivos
-- ------------------------------------------------------------
-- Guarda los tokens de Firebase Cloud Messaging (FCM) asociados
-- a cada usuario. Permite enviar notificaciones push segmentadas.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.dispositivos (
  id_dispositivo uuid NOT NULL DEFAULT gen_random_uuid(),
  id_usuario uuid NOT NULL,
  fcm_token text NOT NULL,
  plataforma text, -- 'android', 'ios', 'web'
  modelo text,
  fecha_registro timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT dispositivos_pkey PRIMARY KEY (id_dispositivo),
  CONSTRAINT dispositivos_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario) ON DELETE CASCADE,
  CONSTRAINT dispositivos_fcm_token_unique UNIQUE (fcm_token)
);

-- Política RLS: un usuario solo puede ver/gestionar sus propios dispositivos
ALTER TABLE public.dispositivos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuarios pueden ver sus propios dispositivos"
  ON public.dispositivos
  FOR SELECT
  USING (auth.uid() = id_usuario);

CREATE POLICY "Usuarios pueden insertar sus propios dispositivos"
  ON public.dispositivos
  FOR INSERT
  WITH CHECK (auth.uid() = id_usuario);

CREATE POLICY "Usuarios pueden actualizar sus propios dispositivos"
  ON public.dispositivos
  FOR UPDATE
  USING (auth.uid() = id_usuario);

CREATE POLICY "Usuarios pueden eliminar sus propios dispositivos"
  ON public.dispositivos
  FOR DELETE
  USING (auth.uid() = id_usuario);


-- ------------------------------------------------------------
-- 2. Campo adjuntos en historial_clinico
-- ------------------------------------------------------------
-- Permite guardar URLs de archivos subidos a Supabase Storage.
-- ------------------------------------------------------------
ALTER TABLE public.historial_clinico
ADD COLUMN IF NOT EXISTS adjuntos text[] DEFAULT '{}'::text[];


-- ------------------------------------------------------------
-- 3. Bucket de Supabase Storage: historiales
-- ------------------------------------------------------------
-- Debes crear el bucket desde la UI de Supabase o con SQL:
-- INSERT INTO storage.buckets (id, name, public) VALUES ('historiales', 'historiales', true);
--
-- Políticas recomendadas (ajustar según necesidades de seguridad):
-- CREATE POLICY "Usuarios autenticados pueden leer historiales"
--   ON storage.objects FOR SELECT
--   USING (bucket_id = 'historiales');
--
-- CREATE POLICY "Médicos pueden subir historiales"
--   ON storage.objects FOR INSERT
--   WITH CHECK (
--     bucket_id = 'historiales'
--     AND auth.uid() IN (
--       SELECT id_medico FROM public.medico
--     )
--   );
