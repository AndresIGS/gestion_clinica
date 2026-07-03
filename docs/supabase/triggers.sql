CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  v_id_rol       INTEGER;
  v_telefono     TEXT;
  v_nombre       TEXT;
  v_especialidad INTEGER;
  v_matricula    TEXT;
  v_fecha_nac    TEXT;
BEGIN
  -- Extrae los metadatos enviados desde Flutter en `data: {...}`
  v_id_rol       := (NEW.raw_user_meta_data->>'id_rol')::INTEGER;
  v_telefono     := NEW.raw_user_meta_data->>'telefono';
  v_nombre       := NEW.raw_user_meta_data->>'nombre_completo';
  v_especialidad := (NEW.raw_user_meta_data->>'id_especialidad')::INTEGER;
  v_matricula    := NEW.raw_user_meta_data->>'matricula_medica';
  v_fecha_nac    := NEW.raw_user_meta_data->>'fecha_nacimiento';

  -- Crea el usuario en la tabla pública usando el mismo UUID de auth
  INSERT INTO public.usuario (
    id_usuario,
    id_rol,
    nombre_completo,
    correo,
    telefono
  ) VALUES (
    NEW.id,
    COALESCE(v_id_rol, 4),
    COALESCE(v_nombre, 'Sin nombre'),
    NEW.email,
    v_telefono
  );

  -- Si el rol es médico (3), crea el registro en la tabla medico.
  -- id_medico es FK a public.usuario(id_usuario), por lo que usa el mismo UUID.
  IF v_id_rol = 3 THEN
    INSERT INTO public.medico (
      id_medico,
      id_especialidad,
      matricula_medica
    ) VALUES (
      NEW.id,
      v_especialidad,
      COALESCE(v_matricula, 'PENDIENTE')
    );
  END IF;

  -- Si el rol es paciente (4), crea el registro en la tabla paciente.
  -- id_paciente es FK a public.usuario(id_usuario), por lo que usa el mismo UUID.
  IF v_id_rol = 4 THEN
    INSERT INTO public.paciente (
      id_paciente,
      fecha_nacimiento
    ) VALUES (
      NEW.id,
      COALESCE(v_fecha_nac::DATE, CURRENT_DATE)
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();


-- ------------------------------------------------------------
-- Trigger: historial de cambios de estado en citas
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_cita_status_change()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.estado IS DISTINCT FROM NEW.estado THEN
    INSERT INTO public.historial_cita (
      id_cita,
      id_usuario_accion,
      estado_anterior,
      estado_nuevo,
      comentario,
      fecha_cambio
    ) VALUES (
      NEW.id_cita,
      auth.uid(),
      OLD.estado,
      NEW.estado,
      'Cambio automático registrado por trigger',
      NOW()
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_cita_status_change ON public.cita;
CREATE TRIGGER on_cita_status_change
  AFTER UPDATE ON public.cita
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_cita_status_change();


-- ------------------------------------------------------------
-- Trigger opcional: enviar notificación push al cambiar estado
-- ------------------------------------------------------------
-- Requiere:
--   1. Extensión pg_net habilitada: CREATE EXTENSION IF NOT EXISTS pg_net;
--   2. Edge Function send-push-notification desplegada.
--   3. Variables de entorno configuradas en Supabase.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.notify_cita_status_change()
RETURNS TRIGGER AS $$
DECLARE
  v_paciente_nombre TEXT;
  v_titulo TEXT;
  v_cuerpo TEXT;
BEGIN
  IF OLD.estado IS DISTINCT FROM NEW.estado THEN
    SELECT u.nombre_completo INTO v_paciente_nombre
    FROM public.usuario u
    WHERE u.id_usuario = NEW.id_paciente;

    v_titulo := 'Actualización de tu cita';
    v_cuerpo := format('Tu cita ahora está: %s', NEW.estado);

    -- Notifica al paciente
    PERFORM net.http_post(
      url := 'https://<tu-proyecto>.supabase.co/functions/v1/send-push-notification',
      headers := jsonb_build_object(
        'Authorization', 'Bearer ' || current_setting('app.service_role_key', true),
        'Content-Type', 'application/json'
      ),
      body := jsonb_build_object(
        'id_usuario_destino', NEW.id_paciente,
        'titulo', v_titulo,
        'cuerpo', v_cuerpo,
        'data', jsonb_build_object('id_cita', NEW.id_cita, 'estado', NEW.estado)
      )
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_cita_status_notify ON public.cita;
CREATE TRIGGER on_cita_status_notify
  AFTER UPDATE ON public.cita
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_cita_status_change();


-- ------------------------------------------------------------
-- Función RPC opcional: historial con nombres de paciente y médico
-- ------------------------------------------------------------
-- Esta función devuelve el historial de citas con los nombres completos
-- del paciente y del médico, evitando joins complejos desde Flutter.
-- Llámala desde la app con: supabase.rpc('obtener_historial_citas')
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.obtener_historial_citas()
RETURNS TABLE (
  id_historial INTEGER,
  id_cita INTEGER,
  estado_anterior TEXT,
  estado_nuevo TEXT,
  fecha_cambio TIMESTAMPTZ,
  fecha_cita TIMESTAMPTZ,
  nombre_paciente TEXT,
  nombre_medico TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    hc.id_historial,
    hc.id_cita,
    hc.estado_anterior::TEXT,
    hc.estado_nuevo::TEXT,
    hc.fecha_cambio,
    c.fecha_hora AS fecha_cita,
    pu.nombre_completo AS nombre_paciente,
    mu.nombre_completo AS nombre_medico
  FROM public.historial_cita hc
  JOIN public.cita c ON c.id_cita = hc.id_cita
  JOIN public.paciente p ON p.id_paciente = c.id_paciente
  JOIN public.usuario pu ON pu.id_usuario = p.id_paciente
  JOIN public.medico m ON m.id_medico = c.id_medico
  JOIN public.usuario mu ON mu.id_usuario = m.id_medico
  ORDER BY hc.fecha_cambio DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
